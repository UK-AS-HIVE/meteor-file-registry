Package.describe({
  summary: "Provides collection FileRegistry, which stores a manifest of all user-contributed files known to the app.",
  name: "hive:file-registry"
});

Package.onUse(function(api, where) {
  api.versionsFrom("METEOR@1.0");
  api.use(['coffeescript', 'aldeed:collection2@2.2.0'], ['client', 'server']);
  api.addFiles(['file-registry.coffee'], ['client', 'server'])
  api.export(['FileRegistry'], ['client', 'server']);
});

