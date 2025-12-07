#include <napi.h>

typedef struct TSLanguage TSLanguage;

extern "C" TSLanguage *tree_sitter_antlers();

// "tree-sitter", "language" hance the name "tree_sitter_language"
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports["name"] = Napi::String::New(env, "antlers");
  auto language = Napi::External<TSLanguage>::New(env, tree_sitter_antlers());
  exports["language"] = language;
  return exports;
}

NODE_API_MODULE(tree_sitter_antlers_binding, Init)
