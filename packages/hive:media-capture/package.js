Package.describe({
  name: "hive:media-capture",
  summary: "Mobile and desktop media capture.",
  version: "0.1.0"
});

Cordova.depends({
  "org.apache.cordova.media-capture": "0.3.2"
});

Package.onUse(function(api) {
  api.versionsFrom("METEOR@0.9.4");
  api.use('hive:uploads');
  api.use(['coffeescript']);

  api.addFiles('common.coffee', 'client');
  api.addFiles('cordova.coffee', 'web.cordova');
  api.addFiles('web.coffee', 'web.browser');
});

