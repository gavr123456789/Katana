project('katana', ['c', 'vala'], 
  version: '0.3.0',
  meson_version: '>= 0.50.0',
)

i18n = import('i18n')

add_project_arguments('--enable-experimental-non-null', language:'vala')

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
