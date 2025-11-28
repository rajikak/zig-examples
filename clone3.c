#define _GNU_SOURCE
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sched.h>


struct Arguments {
	int n;
	char buf[100];
};

static int child(void *arg) {
	struct Arguments *input = (struct Arguments*)arg;

	sleep(3);
	printf("child: n = '%d', args = '%s'\n", input->n, input->buf);
	strcpy(input->buf, "arguments received successfully");
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

	struct Arguments arg;
	arg.n = 5; 
	strcpy(arg.buf, "gcc -wall -ansi -Wall -pedantic");

	if (clone(child, stack + STACK_SIZE, flags | SIGCHLD, &arg) == -1) {
		perror("clone");
		exit(1);
	}

	int status;
	if(wait(&status) == -1) {
		perror("wait");
		exit(1);
	}

	printf("parenet: child exited with status '%d', message from child = '%s'\n", status, arg.buf);
	return 0;
}
