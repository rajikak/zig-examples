#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/mount.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <signal.h>
#include <stdio.h>

#define STACK_SIZE (1024 * 1024)
static char child_stack[STACK_SIZE];

static int childf(void *arg) {
	printf("child: PID  = %ld\n", (long)getpid());
	printf("child: PPID = %ld\n", (long)getppid());

	char *mount_point = arg;
	if (mount_point != NULL) {
		mkdir(mount_point, 0555);
		if (mount("proc", mount_point, "proc", 0, NULL) == -1) {
			fprintf(stderr, "error in mount(): %s\n", mount_point);
		}
		execlp("sleep", "sleep", "600", (char *) NULL);
	}
}

int main(int argc, char *argv[]) {
	pid_t child_pid;

	child_pid = clone(childf, child_stack + STACK_SIZE, CLONE_NEWPID | SIGCHLD, argv[1]);

	if (child_pid == -1) {
		fprint(stderr, "clone error: %s\n", perror());
		return -1;
	}

	printf("PID returned by clone(): %ld\n", (long) child_pid);

	if (waitpid(child_pid, NULL, 0) == -1) {
		fprintf(stderr, "waitpid error: %s\n", perror());
		return -1;
	}

	return 0;
}
