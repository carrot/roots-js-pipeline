js_pipeline = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]
  extensions: [js_pipeline(main: "js/manifest.yml", out: 'js/build.js')]
