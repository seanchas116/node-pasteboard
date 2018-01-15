#include <nan.h>
#import <Cocoa/Cocoa.h>

static NSString *toNSString(const v8::Local<v8::String>& string) {
    v8::String::Utf8Value utf8(string);
    return [NSString stringWithUTF8String:*utf8];
}

static NSString *mimeToUTI(NSString *mime) {
    CFStringRef mimeType = (__bridge CFStringRef)mime;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    return (__bridge_transfer NSString *)uti;
}

static NSImage *imageFromPixels(size_t width, size_t height, uint8_t *rawData) {
    auto provider = CGDataProviderCreateWithData(NULL, rawData, width * height * 4, NULL);
    auto imageRef = CGImageCreate(width, height, 8, 32, width * 4,
                                  CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), // TODO: is this color space is correct?
                                  kCGBitmapByteOrderDefault,
                                  provider,
                                  nullptr,
                                  false,
                                  kCGRenderingIntentDefault);

    auto imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    auto image = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [image addRepresentation:imageRep];
    CFRelease(provider);
    CFRelease(imageRef);
    return image;
}

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

    NSMutableArray<id<NSPasteboardWriting>> *pasteboardItems = [NSMutableArray array];

    auto textKey = Nan::New("text").ToLocalChecked();
    if (values->Has(textKey)) {
        auto text = values->Get(textKey);
        if (!text->IsString()) {
            Nan::ThrowTypeError("Text must be String");
            return;
        }
        [pasteboardItems addObject: toNSString(text->ToString())];
    }

    auto imageKey = Nan::New("image").ToLocalChecked();
    if (values->Has(imageKey)) {
        auto image = values->Get(imageKey);
        if (!image->IsObject()) {
            Nan::ThrowTypeError("Image must be Object");
            return;
        }
        auto imageObj = image->ToObject();
        auto width = imageObj->Get(Nan::New("width").ToLocalChecked());
        auto height = imageObj->Get(Nan::New("height").ToLocalChecked());
        auto data = imageObj->Get(Nan::New("data").ToLocalChecked());
        if (!width->IsNumber() || !height->IsNumber()) {
            Nan::ThrowTypeError("width & height must be Number");
            return;
        }
        if (!data->IsArrayBufferView()) {
            Nan::ThrowTypeError("data must be ArrayBufferView");
            return;
        }
        size_t w = width->ToNumber()->Int32Value();
        size_t h = height->ToNumber()->Int32Value();
        auto array = v8::Local<v8::ArrayBufferView>::Cast(data);
        if (w * h * 4 != array->ByteLength()) {
            Nan::ThrowTypeError("The length of data is wrong");
        }
        auto p = (uint8_t *)array->Buffer()->GetContents().Data() + array->ByteOffset();

        auto nsImage = imageFromPixels(w, h, p);
        [pasteboardItems addObject:nsImage];
    }

    auto dataKey = Nan::New("data").ToLocalChecked();
    if (values->Has(dataKey)) {
        auto datas = values->Get(dataKey);
        if (!datas->IsObject()) {
            Nan::ThrowTypeError("Data map must be Object");
            return;
        }
        auto pasteboardItem = [[NSPasteboardItem alloc] init];

        auto dataObject = datas->ToObject();
        auto dataKeys = dataObject->GetPropertyNames();
        for (size_t i = 0; i < dataKeys->Length(); ++i) {
            auto mime = dataKeys->Get(i);
            auto data = dataObject->Get(mime);
            auto uti = mimeToUTI(toNSString(mime->ToString()));
            if (data->IsString()) {
                [pasteboardItem setString:toNSString(data->ToString()) forType:uti];
            } else if (node::Buffer::HasInstance(data)) {
                auto bytes = node::Buffer::Data(data);
                auto length = node::Buffer::Length(data);
                auto data = [NSData dataWithBytes:bytes length:length];
                [pasteboardItem setData:data forType:uti];
            } else {
                Nan::ThrowTypeError("Data value must be String or Buffer");
                return;
            }
        }
        [pasteboardItems addObject: pasteboardItem];
    }

    auto pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard writeObjects:pasteboardItems];
}

static void hasImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}

static void hasText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto pasteboard = [NSPasteboard generalPasteboard];
    bool contains = [pasteboard.types containsObject:NSPasteboardTypeString];
    info.GetReturnValue().Set(Nan::New(contains));
}

static void hasData(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    if (info.Length() < 1) {
        Nan::ThrowTypeError("Wrong number of arguments");
        return;
    }
    if (!info[0]->IsString()) {
        Nan::ThrowTypeError("Argument must be String");
        return;
    }
    auto pasteboard = [NSPasteboard generalPasteboard];
    auto uti = mimeToUTI(toNSString(info[0]->ToString()));
    bool contains = [pasteboard.types containsObject:uti];
    info.GetReturnValue().Set(Nan::New(contains));
}

static void getImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
}

static void getText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto pasteboard = [NSPasteboard generalPasteboard];
    auto text = [pasteboard stringForType:NSPasteboardTypeString];
    info.GetReturnValue().Set(Nan::New([text UTF8String]).ToLocalChecked());
}

static void getDataBuffer(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    if (info.Length() < 1) {
        Nan::ThrowTypeError("Wrong number of arguments");
        return;
    }
    if (!info[0]->IsString()) {
        Nan::ThrowTypeError("Argument must be String");
        return;
    }
    auto pasteboard = [NSPasteboard generalPasteboard];
    auto uti = mimeToUTI(toNSString(info[0]->ToString()));
    auto data = [pasteboard dataForType:uti];
    if (data != nil) {
        auto maybeBuffer = Nan::CopyBuffer((char *)data.bytes, data.length);
        if (!maybeBuffer.IsEmpty()) {
            info.GetReturnValue().Set(maybeBuffer.ToLocalChecked());
        }
    }
}

static void getDataString(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    if (info.Length() < 1) {
        Nan::ThrowTypeError("Wrong number of arguments");
        return;
    }
    if (!info[0]->IsString()) {
        Nan::ThrowTypeError("Argument must be String");
        return;
    }
    auto pasteboard = [NSPasteboard generalPasteboard];
    auto uti = mimeToUTI(toNSString(info[0]->ToString()));
    auto string = [pasteboard stringForType:uti];
    if (string != nil) {
        info.GetReturnValue().Set(Nan::New([string UTF8String]).ToLocalChecked());
    }
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
  exports->Set(Nan::New("getDataBuffer").ToLocalChecked(),
               Nan::New<v8::FunctionTemplate>(getDataBuffer)->GetFunction());
    exports->Set(Nan::New("getDataString").ToLocalChecked(),
                 Nan::New<v8::FunctionTemplate>(getDataString)->GetFunction());
}

NODE_MODULE(pasteboard, InitModule)
