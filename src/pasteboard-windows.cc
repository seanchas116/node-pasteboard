#include <Windows.h>
#include "pasteboard.hh"

class PasteboardWriterWindows : public PasteboardWriter {
public:
    PasteboardWriterWindows() {
        OpenClipboard(nullptr);
    }
    ~PasteboardWriterWindows() {
        CloseClipboard();
    }
    void writeText(const std::string &text) {

    }
    void writeImage(const ImageData &image) {

    }
    void writeData(const std::string &type, std::string &text) {

    }
    void writeData(const std::string &type, const std::vector<uint8_t> &data) {

    }
};

std::unique_ptr<PasteboardWriter> createWriter() {
    return std::unique_ptr<PasteboardWriter>(new PasteboardWriterWindows());
}

class PasteboardReaderWindows : public PasteboardReader {
public:
    PasteboardReaderWindows() {
        OpenClipboard(nullptr);
    }
    ~PasteboardReaderWindows() {
        CloseClipboard();
    }
    bool hasText() {
        return false;
    }
    bool hasImage() {
        return false;
    }
    bool hasData(const std::string &type) {
        return false;
    }
    std::string readText() {
        return "";
    }
    ImageData readImage() {
        return ImageData();
    }
    std::string readDataString(const std::string &type) {
        return "";
    }
    std::vector<uint8_t> readDataBuffer(const std::string &type) {
        return {};
    }
};

std::unique_ptr<PasteboardReader> createReader() {
    return std::unique_ptr<PasteboardReader>(new PasteboardReaderWindows());
}
