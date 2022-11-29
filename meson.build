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
  ),
]
c_focus_link_args=['-Wl,-framework,Foundation','-Wl,-framework,AppKit']

#############################################################################
c_focus_lib = static_library('c_focus',
  ['src/c_focus.m','src/c_focus.h'],
  install: false,
  dependencies: [],
  c_args: [],
  link_args: c_focus_link_args,
  include_directories: [inc]
)

c_focus_dep = declare_dependency(
  include_directories: ['src'],
  link_with: c_focus_lib,
  link_args: c_focus_link_args,
)

c_focus_example_block_exec = executable('example_block',
  ['example_block.c'],
  dependencies:[c_focus_dep],
  install: false,
  link_args: [],

  )
c_focus_example_exec = executable('example',
  ['example.c'],
  dependencies:[c_focus_dep],
  install: false,
  link_args: [],

  )
