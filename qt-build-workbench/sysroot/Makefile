# 获取当前目录下所有以.dockerfile结尾的文件名
DOCKERFILES := $(wildcard *.dockerfile)

# 提取文件名作为目标
TARGETS_SYSROOT := $(patsubst %.dockerfile,%,$(DOCKERFILES))

# 默认目标，执行所有目标
all: $(TARGETS_SYSROOT)
	@echo "All targets built successfully"

# 每个目标执行动作
$(TARGETS_SYSROOT):
	@echo "Building $@ ..."
	@docker buildx build . -t $@ -f $@.dockerfile
	@if [ $$? -ne 0 ]; then \
		echo Image build failed!; \
		exit 1; \
	fi
	@echo "Creating container for $@ ..."
	@docker create --name $@-container $@
	@if [ $$? -ne 0 ]; then \
		echo Container creation failed!; \
		exit 1; \
	fi
	@echo "Copying sysroot from $@ ..."
	@docker cp $@-container:/root/sysroot.tar.gz $@.tar.gz
	@if [ $$? -ne 0 ]; then \
		echo File copy failed!; \
		exit 1; \
	fi
	@echo "Removing container $@-container ..."
	@docker rm $@-container
	@if [ $$? -ne 0 ]; then \
		echo Container removal failed!; \
		exit 1; \
	fi
	@echo Image build completed for $@!

clean:
	@echo "Cleaning up"
	docker rmi $(TARGETS_SYSROOT)

.PHONY: all clean $(TARGETS_SYSROOT)
