#include "pasteboard.hh"
#include <cmath>
#import <Cocoa/Cocoa.h>

static NSImage *toNSImage(const ImageData& data) {
    auto buffer = new uint8_t[data.data.size()];
    auto releaseBuffer = [](void *info, const void *data, size_t size) {
        delete[] (const uint8_t *)data;
    };
    memcpy(buffer, data.data.data(), data.data.size());
    auto provider = CGDataProviderCreateWithData(NULL, buffer, data.width * data.height * 4, releaseBuffer);
    auto colorSpace = CGColorSpaceCreateDeviceRGB();
    // auto colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    auto imageRef = CGImageCreate(data.width, data.height, 8, 32, data.width * 4,
                                  colorSpace,
                                  kCGBitmapByteOrderDefault | kCGImageAlphaLast,
                                  provider,
                                  nullptr,
                                  false,
                                  kCGRenderingIntentDefault);

    auto imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    auto image = [[NSImage alloc] initWithSize:NSMakeSize(data.width, data.height)];
    [image addRepresentation:imageRep];
    CFRelease(provider);
    CFRelease(colorSpace);
    CFRelease(imageRef);
    return image;
}

static ImageData toImageData(NSImage *image) {
    ImageData data;
    data.width = image.size.width;
    data.height = image.size.height;
    data.data.resize(data.width * data.height * 4);
    auto rawData = data.data.data();

    auto colorSpace = CGColorSpaceCreateDeviceRGB();
    auto bitmapContext = CGBitmapContextCreate(rawData, data.width, data.height, 8, data.width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    auto rect = NSMakeRect(0, 0, data.width, data.height);
    auto cgImage = [image CGImageForProposedRect:&rect context:[NSGraphicsContext currentContext] hints:nil];
    CGContextDrawImage(bitmapContext, NSRectToCGRect(rect), cgImage);
    CFRelease(bitmapContext);
    CFRelease(colorSpace);

    for (size_t i = 0; i < data.width * data.height; ++i) {
        double a = rawData[i * 4 + 3];
        double unmult = 255.0 / a;
        rawData[i * 4] = std::round(rawData[i * 4] * unmult);
        rawData[i * 4 + 1] = std::round(rawData[i * 4 + 1] * unmult);
        rawData[i * 4 + 2] = std::round(rawData[i * 4 + 2] * unmult);
    }

    return data;
}

class PasteboardWriterMac : public PasteboardWriter {
public:
    PasteboardWriterMac() {
        _items = @[].mutableCopy;
    }

    ~PasteboardWriterMac() {
        auto pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:_items];
    }

    void writeText(const std::string &text) override {
        [_items addObject:[NSString stringWithUTF8String:text.c_str()]];
    }

    void writeImage(const ImageData &image) override {
        auto nsImage = toNSImage(image);
        [_items addObject:nsImage];
    }

    void writeData(const std::string &type, std::string &text) override {
        auto item = [[NSPasteboardItem alloc] init];
        auto uti = [NSString stringWithUTF8String:type.c_str()];
        auto string = [NSString stringWithUTF8String:text.c_str()];
        [item setString:string forType:uti];
        [_items addObject:item];
    }

    void writeData(const std::string &type, const std::vector<uint8_t> &data) override {
        auto item = [[NSPasteboardItem alloc] init];
        auto uti = [NSString stringWithUTF8String:type.c_str()];
        auto nsData = [NSData dataWithBytes:data.data() length:data.size()];
        [item setData:nsData forType:uti];
        [_items addObject:item];
    }
private:
    NSMutableArray<id<NSPasteboardWriting>> *_items;
};

std::unique_ptr<PasteboardWriter> createWriter() {
    return std::unique_ptr<PasteboardWriter>(new PasteboardWriterMac());
}

class PasteboardReaderMac : public PasteboardReader {
public:
    bool hasText() {
        auto pasteboard = [NSPasteboard generalPasteboard];
        return [pasteboard.types containsObject:NSPasteboardTypeString];
    }

    bool hasImage() {
        auto pasteboard = [NSPasteboard generalPasteboard];
        return [pasteboard canReadObjectForClasses:@[[NSImage class]] options:@{}];
    }

    bool hasData(const std::string &type) {
        auto pasteboard = [NSPasteboard generalPasteboard];
        auto uti = [NSString stringWithUTF8String:type.c_str()];
        return [pasteboard.types containsObject:uti];
    }

    std::string readText() {
        auto pasteboard = [NSPasteboard generalPasteboard];
        auto text = [pasteboard stringForType:NSPasteboardTypeString];
        if (text == nil) {
            return "";
        }
        return [text UTF8String];
    }

    ImageData readImage() {
        auto pasteboard = [NSPasteboard generalPasteboard];
        auto images = [pasteboard readObjectsForClasses:@[[NSImage class]] options:@{}];
        if (images != nil && images.count > 0) {
            NSImage *image = images[0];
            return toImageData(image);
        } else {
            return ImageData();
        }
    }

    std::string readDataString(const std::string &type) {
        auto pasteboard = [NSPasteboard generalPasteboard];
        auto uti = [NSString stringWithUTF8String:type.c_str()];
        auto string = [pasteboard stringForType:uti];
        if (string == nil) {
            return "";
        }
        return [string UTF8String];
    }

    std::vector<uint8_t> readDataBuffer(const std::string &type) {
        auto pasteboard = [NSPasteboard generalPasteboard];
        auto uti = [NSString stringWithUTF8String:type.c_str()];
        auto nsData = [pasteboard dataForType:uti];
        if (nsData == nil) {
            return {};
        }
        std::vector<uint8_t> data(nsData.length);
        memcpy(data.data(), nsData.bytes, data.size());
        return data;
    }
};

std::unique_ptr<PasteboardReader> createReader() {
    return std::unique_ptr<PasteboardReader>(new PasteboardReaderMac());
}
