CC = /usr/bin/gcc
CROSS_GCC = /home/connor/workspace/webtool/tool/gcc-linaro-7.5.0-2019.12-i686_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc
CFLAGS = -Wall -Werror -g
LDFLAGS = -lcrypto -lssl

all: build

build: client.h server.h
	$(CC) $(CFLAGS) -o openssl main.c client.c server.c $(LDFLAGS)
target: client.h server.h
	$(CROSS_GCC)  -o openssl main.c client.c server.c -L./dynamicLib $(LDFLAGS) -I./include

clean:
	rm -f *.o core openssl
