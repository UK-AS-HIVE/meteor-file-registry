Package.describe({
  summary: "Provides collection FileRegistry, which stores a manifest of all user-contributed files known to the app.",
  name: "hive:file-registry"
});

Package.onUse(function(api, where) {
  api.versionsFrom("METEOR@1.0");
  api.use(['coffeescript', 'aldeed:collection2@2.2.0', 'mongo'], ['client', 'server']);
  api.use('differential:workers@2.0.0','server')
  api.addFiles(['file-registry.coffee'], ['client', 'server'])
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
    'file-registy-test.coffee',
    ], ['client', 'server']);
});

