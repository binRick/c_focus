.default=all

meson:
	@[[ -d build ]] || meson setup build
	@meson setup build --reconfigure
	@meson compile -C build

build: meson

clean:
	@rm -rf build
all: meson 
tidy:
	@uncrustify -c ~/repos/c_deps/etc/uncrustify.cfg --replace examples/example_block.c examples/example_callback.c examples/focus_logger.c examples/common.h src/c_focus.h src/c_focus.m
	@rm *unc-backup* */*unc-backup* 2>/dev/null||true

install: build
	@meson install -C build

