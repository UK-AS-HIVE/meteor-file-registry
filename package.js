Package.describe({
  summary: "Implements a file manifest and uploads for Meteor applications.",
  name: "hive:file-registry",
  version: "0.9.15",
  git: "https://github.com/UK-AS-HIVE/meteor-file-registry"
});

Npm.depends({mime: '1.3.4'});

Cordova.depends({
  "org.apache.cordova.media-capture": "0.3.2"
});

Package.onUse(function(api, where) {
  api.versionsFrom("METEOR@1.0");
  api.use(['coffeescript', 'aldeed:collection2@2.2.0', 'mongo', 'jquery', 'check'], ['client', 'server']);
  api.use('hive:workers@2.0.5','server');
  api.addFiles(['file-registry.coffee'], ['client', 'server']);
  api.addFiles('jobs.coffee', 'server');
  api.addFiles('uploads.coffee', ['client','server']);
  api.addFiles('cordova.coffee', 'web.cordova');
  api.addFiles('web.coffee', 'web.browser');
  api.export(['FileRegistry'], ['client', 'server']);
});

Package.onTest(function (api) {
  api.use('coffeescript');
  api.use('underscore');
  api.use('hive:file-registry');
  api.use('tinytest');
  api.use('test-helpers');
  api.use('hive:workers@2.0.5');
/*
  api.addFiles([
    'file-registry-test.coffee',
    ], ['client', 'server']);
    */
});

