#define _GNU_SOURCE
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sched.h>


static int child(void *arg) {
	char *input = (char *)arg;

	printf("child:args = '%s', tid = '%d', pid = '%d'\n", input, gettid(), getpid());
	strcpy(input, "arguments received successfully");
	return 0;
}

int main(int argc, char **argv) {
	
	// allocate stack for the child
	const int STACK_SIZE = 1024 * 1024;
	char *stack = malloc(STACK_SIZE);
	if (!stack) {
		perror("malloc");
		exit(1);
	}

	unsigned long flags = 0;
	if (argc > 1 && !strcmp(argv[1], "vm")) {
		flags |= CLONE_VM;
	}

	char buf[100];
	strcpy(buf, "gcc -wall -ansi -Wall -pedantic");

	if (clone(child, stack + STACK_SIZE, flags | SIGCHLD, &buf) == -1) {
		perror("clone");
		exit(1);
	}

	int status;
	if(wait(&status) == -1) {
		perror("wait");
		exit(1);
	}

	printf("parenet: child exited with status '%d', tid = '%d', pid = '%d', message from child = '%s'\n", status, gettid(), getpid(), buf);
	return 0;
}
