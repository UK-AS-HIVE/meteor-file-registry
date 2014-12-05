Package.describe({
  name: 'hive:uploads',
  summary: ' /* Fill me in! */ ',
  version: '1.0.0',
  git: ' /* Fill me in! */ '
});

Package.onUse(function(api) {
  api.use('coffeescript');
  api.use('hive:file-registry','server');
  api.versionsFrom('1.0');
  api.addFiles('server.coffee','server');
});

