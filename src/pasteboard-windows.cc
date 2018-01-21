#include "pasteboard.hh"

class PasteboardWriterWindows : public PasteboardWriter {
public:
    PasteboardWriterWindows() {
    }
    ~PasteboardWriterWindows() {
    }
    void writeText(const std::string &text) {

    }
    void writeImage(const ImageData &image) {

    }
    void writeData(const std::string &mimeType, std::string &text) {

    }
    void writeData(const std::string &mimeType, const std::vector<uint8_t> &data) {

    }
};

std::unique_ptr<PasteboardWriter> createWriter() {
    return std::unique_ptr<PasteboardWriter>(new PasteboardWriterWindows());
}

class PasteboardReaderWindows : public PasteboardReader {
public:
    PasteboardReaderWindows() {

    }
    ~PasteboardReaderWindows() {
    }
    bool hasText() {

    }
    bool hasImage() {

    }
    bool hasData(const std::string &mimeType) {

    }
    std::string readText() {

    }
    ImageData readImage() {

    }
    std::string readDataString(const std::string &mimeType) {

    }
    std::vector<uint8_t> readDataBuffer(const std::string &mimeType) {

    }
};

std::unique_ptr<PasteboardReader> createReader() {
    return std::unique_ptr<PasteboardReader>(new PasteboardReaderWindows());
}
