project('c_focus',['c', 'cpp', 'objc', 'objcpp'],
  default_options: ['warning_level=0','c_std=gnu99','default_library=static'],
  version: '0.0.1',
  )
cc = meson.get_compiler('c')
pwd = meson.current_source_dir()
inc = [
  include_directories(
    'src',
    '.',
    'dist','dist/src','dist/include',
    'submodules',
  ),
]
c_focus_util_link_args=[
  ]
c_focus_link_args=[
  '-Wl,-framework,CoreFoundation',
  '-Wl,-framework,Foundation',
  '-Wl,-framework,AppKit',
  '-Wl,-framework,SkyLight',
  '-F/System/Library/PrivateFrameworks',
]

c_focus_util_sources = [
  'dist/src/stringbuffer.c',
  'dist/src/fsio.c',
  'dist/src/stringfn.c',
]

c_focus_sources = [
  'src/c_focus.h',
  'src/c_focus.m',
]

#############################################################################
c_focus_util_lib = static_library('c_focus_util',
  files(c_focus_util_sources),
  install: false,
  dependencies: [],
  c_args: [],
  link_args: c_focus_util_link_args,
  include_directories: [inc]
)
c_focus_lib = static_library('c_focus',
  files(c_focus_sources),
  install: false,
  dependencies: [],
  c_args: [],
  link_args: c_focus_link_args,
  link_whole: [c_focus_util_lib],
  include_directories: [inc]
)

c_focus_dep = declare_dependency(
  include_directories: ['src'],
  link_with: c_focus_lib,
  link_args: c_focus_link_args,
)

c_focus_example_block_exec = executable('example_block',
  ['examples/example_block.c'],
  dependencies:[c_focus_dep],
  install: false,
  link_args: [],

  )
c_focus_example_exec = executable('focus_logger',
  ['examples/focus_logger.c'],
  dependencies:[c_focus_dep],
  link_whole: [c_focus_util_lib],
  install: true,
  link_args: [],

  )
c_focus_example_exec = executable('example_callback',
  ['examples/example_callback.c'],
  dependencies:[c_focus_dep],
  install: false,
  link_args: [],

  )
