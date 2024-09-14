#include <fcntl.h>
#include <linux/input.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define WACOM_PATH "/dev/input/event1"
#define EVENTS_BUFFER_LEN 32

int main(int argc, char** argv) {
	int fd = open(WACOM_PATH, O_RDWR);
	if (fd < 0)
		return EXIT_FAILURE;

	struct input_event events[EVENTS_BUFFER_LEN];
	for (;;) {
		ssize_t bytes = read(fd, events, sizeof events);
		if (bytes < 0) {
			close(fd);
			return EXIT_FAILURE;
		}

		for (size_t i = 0; i < bytes / sizeof (struct input_event); i++) {
			if (events[i].type == EV_KEY && events[i].code == BTN_STYLUS) {
				events[i].code = BTN_TOOL_RUBBER;
				write(fd, &events[i], sizeof(struct input_event));
			}
		}
	}

	close(fd);
	return EXIT_SUCCESS;
}
