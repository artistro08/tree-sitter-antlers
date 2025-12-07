{
  "targets": [
    {
      "target_name": "tree_sitter_antlers_binding",
      "dependencies": [
        "<!(node -p \"require('node-addon-api').targets\"):node_addon_api_except"
      ],
      "include_dirs": [
        "src",
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "sources": [
        "bindings/node/binding.cc",
        "src/parser.c",
        "src/scanner.c"
      ],
      "defines": [
        "NAPI_VERSION=8",
        "NAPI_CPP_EXCEPTIONS"
      ],
      "conditions": [
        ["OS!='win'", {
          "cflags_c": [
            "-std=c11"
          ],
          "cflags_cc": [
            "-std=c++17"
          ]
        }, {
          "msvs_settings": {
            "VCCLCompilerTool": {
              "AdditionalOptions": ["/utf-8"]
            }
          }
        }]
      ]
    }
  ]
}
