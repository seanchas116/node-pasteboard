#include <string>
#include <vector>
#include <memory>

struct ImageData {
    size_t width = 0;
    size_t height = 0;
    std::vector<uint8_t> data;
};

class PasteboardWriter {
public:
    virtual ~PasteboardWriter() {}
    virtual void writeText(const std::string &text) = 0;
    virtual void writeImage(const ImageData &image) = 0;
    virtual void writeData(const std::string &type, std::string &text) = 0;
    virtual void writeData(const std::string &type, const std::vector<uint8_t> &data) = 0;
};

std::unique_ptr<PasteboardWriter> createWriter();

class PasteboardReader {
public:
    virtual ~PasteboardReader() {}
    virtual bool hasText() = 0;
    virtual bool hasImage() = 0;
    virtual bool hasData(const std::string &type) = 0;
    virtual std::string readText() = 0;
    virtual ImageData readImage() = 0;
    virtual std::string readDataString(const std::string &type) = 0;
    virtual std::vector<uint8_t> readDataBuffer(const std::string &type) = 0;
};

std::unique_ptr<PasteboardReader> createReader();
