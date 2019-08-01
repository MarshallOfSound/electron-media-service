{
  "targets": [
    {
      "target_name": "electron_media_service",
      "cflags!": [ "-fno-exceptions" ],
      "cflags_cc!": [ "-fno-exceptions" ],
      "conditions": [
        ["OS==\"mac\"", {
          "sources": [
            "src/darwin/module.mm",
            "src/darwin/service.mm"
          ],
          "libraries": [ "-framework Foundation -framework AppKit -framework MediaPlayer" ]
        }]
      ],
      'include_dirs': [
          "<!@(node -p \"require('node-addon-api').include\")"
      ],
      'libraries': [],
      'dependencies': [
          "<!(node -p \"require('node-addon-api').gyp\")"
      ],
      'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ]
    }
  ]
}