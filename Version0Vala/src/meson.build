giodep = dependency('gio-2.0')
geedep = dependency('gee-0.8')
gtkdep = dependency('gtk+-3.0', version: '>= 3.22')
hdydep = dependency('libhandy-1', version: '>= 0.90')
model_inc = include_directories('Model')


valadeps = [dependency('glib-2.0'), dependency('gobject-2.0')]

katana_sources = [files('main.vala')]

Model_sources = [files(
    'Model/DirectoryNavigator.vala',
    'Model/DirectoryRepository.vala',
    'Model/FolderMonitoring.vala',
    'Model/Helpers.vala',
    'Model/Item.vala')]

#View and Controllers building together because of circular dependencies
Views_and_Controllers_sources = [files(
    'Views/Page.vala',
    'Views/window.vala',
    'Views/RowWidget.vala',
    'Controllers/MainController.vala',
    'Controllers/SelectedFiles.vala')]

katana_sources += Views_and_Controllers_sources


#Model_build
lib_deps = [valadeps, geedep, giodep]
model_lib = static_library('ModelLib', Model_sources, dependencies: lib_deps)

#Views_and_Controllers_build
katana_deps = [
  giodep,
  gtkdep,
  geedep,
  hdydep
]

subdir('Views')

executable('katana', katana_sources,
  link_with: model_lib,
  include_directories: model_inc,
  vala_args: '--target-glib=2.50',  dependencies: katana_deps,
  install: true,
)




# subdir('Model')
# subdir('Views')
# subdir('Controllers')
