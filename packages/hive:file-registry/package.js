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
  api.export(['FileRegistry'], ['client', 'server']);
});

