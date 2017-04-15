{
  "targets": [
    {
      "target_name": "electron_media_service",
      "include_dirs" : [
        "<!(node -e \"require('nan')\")"
      ],
      "conditions": [
        ["OS==\"mac\"", {
          "sources": [
            "src/darwin/module.mm",
            "src/darwin/service.mm"
          ],
          "libraries": [ "-framework Foundation -framework AppKit -framework MediaPlayer" ]
        }]
      ]
    }
  ]
}