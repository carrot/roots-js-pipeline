js_pipeline = require '../../..'

module.exports =
  ignores: ["**/_*", "**/.DS_Store"]
  extensions: [js_pipeline(files: "js/**")]
