js_pipeline = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]
  extensions: [js_pipeline(manifest: "js/manifest.yml")]
