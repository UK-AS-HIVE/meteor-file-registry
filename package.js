Package.describe({
  summary: "Implements a file manifest and uploads for Meteor applications.",
  name: "hive:file-registry",
  version: "0.9.4",
  git: "https://github.com/UK-AS-HIVE/meteor-file-registry"
});

Npm.depends({mime: '1.3.4'});

Package.onUse(function(api, where) {
  api.versionsFrom("METEOR@1.0");
  api.use(['coffeescript', 'aldeed:collection2@2.2.0', 'mongo'], ['client', 'server']);
  api.use('differential:workers@2.0.0','server');
  api.addFiles(['file-registry.coffee'], ['client', 'server']);
  api.addFiles('jobs.coffee', 'server');
  api.addFiles('uploads.coffee', ['client','server']);
  api.addFiles('cordova.coffee', 'web.cordova');
  api.addFiles('web.coffee', 'web.browser');
  api.export(['FileRegistry'], ['client', 'server']);
});

Package.onTest(function (api) {
  api.use('coffeescript');
  api.use('hive:file-registry');
  api.use('tinytest');
  api.use('test-helpers');
  api.use('differential:workers@2.0.0');

  api.addFiles([
    'file-registry-test.coffee',
    ], ['client', 'server']);
});

