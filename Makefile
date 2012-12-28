COMPILER= coffee --bare --output $(PWD)/lib/
NODE= $(shell which node)

all: lib

lib:
	$(COMPILER) ./src/

watch:
	$(COMPILER) --watch ./src/

clean:
	rm -rf ./lib/*

.PHONY: all clean