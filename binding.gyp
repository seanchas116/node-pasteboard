{
  "targets": [
    {
      "target_name": "addon",
      "include_dirs": [
        "<!(node -e \"require('nan')\")",
      ],
      "sources": [ "src/index.cc", "src/pasteboard.hh" ],
      "conditions": [
        ['OS=="mac"', {
          "sources": [ "src/pasteboard-mac.mm" ],
          "libraries": [
            "-framework AppKit"
          ],
          "xcode_settings": {
            "OTHER_CFLAGS": [
              "-fobjc-arc"
            ]
          }
        }],
        ['OS=="win"', {
          "sources": [ "src/pasteboard-windows.cc" ]
        }],
        ['OS=="linux"', {
          "sources": [ "src/pasteboard-linux.cc" ]
        }]
      ]
    }
  ]
}
