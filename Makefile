
all: runc-hello.tar.gz

runc-hello.tar.gz: rootfs
	tar \
	-czf runc-hello.tar.gz \
	config.json \
	rootfs

rootfs: runc-hello
	mkdir -p rootfs
	mv runc-hello rootfs/

runc-hello: main.go
	go build
