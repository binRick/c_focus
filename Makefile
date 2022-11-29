.default=all

meson:
	@meson setup build
	@meson compile -C build

build:
	@mkdir -p bin
	@gcc -framework Foundation -framework AppKit example.c src/c_focus.m -I src -o bin/example

test:
	@./bin/example

clean:
	@rm -rf bin/example build


all: meson 
