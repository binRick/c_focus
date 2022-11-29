.default=all

meson:
	@[[ -d build ]] || meson setup build
	@meson setup build --reconfigure
	@meson compile -C build

build:
	@mkdir -p bin
	@gcc -framework Foundation -framework AppKit example.c src/c_focus.m -I src -o bin/example

test:
	@./bin/example

clean:
	@rm -rf bin/example build


all: meson 

tidy:
	@uncrustify -c ~/repos/c_deps/etc/uncrustify.cfg --replace example_block.c example.c src/c_focus.h src/c_focus.m
	@rm *unc-backup* */*unc-backup*
