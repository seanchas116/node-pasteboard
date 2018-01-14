#include <nan.h>
#import <Cocoa/Cocoa.h>

static void set(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    if (info.Length() < 1) {
        Nan::ThrowTypeError("Wrong number of arguments");
        return;
    }
    if (!info[0]->IsObject()) {
        Nan::ThrowTypeError("Argument must be Object");
        return;
    }
    auto values = info[0]->ToObject();
    auto textKey = Nan::New("text").ToLocalChecked();

    NSMutableArray<id<NSPasteboardWriting>> *pasteboardItems = [NSMutableArray array];

    if (values->Has(textKey)) {
        auto text = values->Get(textKey);
        if (!text->IsString()) {
            Nan::ThrowTypeError("Text must be String");
            return;
        }
        v8::String::Utf8Value str(text->ToString());
        [pasteboardItems addObject: [NSString stringWithUTF8String:*str]];
    }

    auto pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:pasteboardItems];
}

static void hasImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}
static void hasText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto pasteboard = [NSPasteboard generalPasteboard];
    auto types = pasteboard.types;
    bool contains = [types containsObject:NSPasteboardTypeString];
    info.GetReturnValue().Set(Nan::New(contains));
}
static void hasData(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}

static void getImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}
static void getText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto pasteboard = [NSPasteboard generalPasteboard];
    auto text = [pasteboard stringForType:NSPasteboardTypeString];
    info.GetReturnValue().Set(Nan::New([text UTF8String]).ToLocalChecked());
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
