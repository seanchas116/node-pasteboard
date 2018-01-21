#include <nan.h>
#include "pasteboard.hh"

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

    auto writer = createWriter();

    auto textKey = Nan::New("text").ToLocalChecked();
    if (values->Has(textKey)) {
        auto text = values->Get(textKey);
        if (!text->IsString()) {
            Nan::ThrowTypeError("Text must be String");
            return;
        }
        writer->writeText(*v8::String::Utf8Value(text));
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
        if (!node::Buffer::HasInstance(data)) {
            Nan::ThrowTypeError("data must be Buffer");
            return;
        }
        ImageData imageData;
        imageData.width = width->ToNumber()->Int32Value();
        imageData.height = height->ToNumber()->Int32Value();
        imageData.data.resize(imageData.width * imageData.height * 4);
        if (imageData.data.size() != node::Buffer::Length(data)) {
            Nan::ThrowTypeError("The length of data is wrong");
        }
        memcpy(imageData.data.data(), node::Buffer::Data(data), imageData.data.size());

        writer->writeImage(imageData);
    }

    auto dataKey = Nan::New("data").ToLocalChecked();
    if (values->Has(dataKey)) {
        auto datas = values->Get(dataKey);
        if (!datas->IsObject()) {
            Nan::ThrowTypeError("Data map must be Object");
            return;
        }
        auto dataObject = datas->ToObject();
        auto dataKeys = dataObject->GetPropertyNames();
        for (size_t i = 0; i < dataKeys->Length(); ++i) {
            auto mime = dataKeys->Get(i);
            auto data = dataObject->Get(mime);
            std::string mimeStr = *v8::String::Utf8Value(mime);
            if (data->IsString()) {
                std::string dataStr = *v8::String::Utf8Value(data->ToString());
                writer->writeData(mimeStr, dataStr);
            } else if (node::Buffer::HasInstance(data)) {
                auto bytes = node::Buffer::Data(data);
                auto length = node::Buffer::Length(data);
                std::vector<uint8_t> dataVector(bytes, bytes + length);
                writer->writeData(mimeStr, dataVector);
            } else {
                Nan::ThrowTypeError("Data value must be String or Buffer");
                return;
            }
        }
    }
}

static void hasImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto reader = createReader();
    info.GetReturnValue().Set(Nan::New(reader->hasImage()));
}

static void hasText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto reader = createReader();
    info.GetReturnValue().Set(Nan::New(reader->hasText()));
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
    auto reader = createReader();
    auto result = reader->hasData(*v8::String::Utf8Value(info[0]->ToString()));
    info.GetReturnValue().Set(Nan::New(result));
}

static void getImage(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto reader = createReader();
    auto imageData = reader->readImage();

    auto arrayBuffer = v8::ArrayBuffer::New(info.GetIsolate(), imageData.data.size());
    auto array = v8::Uint8ClampedArray::New(arrayBuffer, 0, arrayBuffer->ByteLength());
    memcpy(*Nan::TypedArrayContents<uint8_t>(array), imageData.data.data(), imageData.data.size());

    auto obj = Nan::New<v8::Object>();
    obj->Set(Nan::New("width").ToLocalChecked(), Nan::New((int)imageData.width));
    obj->Set(Nan::New("height").ToLocalChecked(), Nan::New((int)imageData.height));
    obj->Set(Nan::New("data").ToLocalChecked(), array);
    info.GetReturnValue().Set(obj);
}

static void getText(const Nan::FunctionCallbackInfo<v8::Value>& info) {
    auto reader = createReader();
    if (reader->hasText()) {
        auto text = reader->readText();
        info.GetReturnValue().Set(Nan::New(text).ToLocalChecked());
    }
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
    auto reader = createReader();
    std::string type = *v8::String::Utf8Value(info[0]->ToString());
    if (reader->hasData(type)) {
        auto data = reader->readDataBuffer(type);
        auto buffer = Nan::CopyBuffer((const char *)data.data(), data.size()).ToLocalChecked();
        info.GetReturnValue().Set(buffer);
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
    auto reader = createReader();
    std::string type = *v8::String::Utf8Value(info[0]->ToString());
    if (reader->hasData(type)) {
        auto str = reader->readDataString(type);
        info.GetReturnValue().Set(Nan::New(str).ToLocalChecked());
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
