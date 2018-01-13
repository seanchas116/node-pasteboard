{
  "targets": [
    {
      "target_name": "addon",
      "include_dirs": [
        "<!(node -e \"require('nan')\")",
      ],
      "conditions": [
        ['OS=="mac"', {
          "sources": [ "src/mac.mm" ]
        }],
        ['OS=="win"', {
          "sources": [ "src/windows.cc" ]
        }],
        ['OS=="linux"', {
          "sources": [ "src/linux.cc" ]
        }]
      ]
    }
  ]
}
