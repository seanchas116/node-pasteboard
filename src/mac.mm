#include <nan.h>

static void set(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}

static void hasImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}
static void hasText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}
static void hasData(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}

static void getImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}
static void getText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}
static void getData(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}

static void InitModule(v8::Local<v8::Object> exports) {
  exports->Set(Nan::New("set").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(set)->GetFunction());
  exports->Set(Nan::New("hasImage").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(hasImage)->GetFunction());
  exports->Set(Nan::New("hasText").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(hasText)->GetFunction());
  exports->Set(Nan::New("hasData").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(hasData)->GetFunction());
  exports->Set(Nan::New("getImage").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(getImage)->GetFunction());
  exports->Set(Nan::New("getText").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(getText)->GetFunction());
  exports->Set(Nan::New("getData").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(getData)->GetFunction());
}

NODE_MODULE(pasteboard, InitModule)
