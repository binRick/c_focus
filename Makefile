.default=build
build:
	@mkdir -p bin
	@gcc -framework Foundation -framework AppKit example.c src/c_focus.m -I src -o bin/example

test:
	@./bin/example

clean:
	@rm -rf bin/example


all: build test
