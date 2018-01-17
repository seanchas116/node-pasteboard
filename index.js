const addon = require('bindings')('addon.node')

const pngDataURLHeader = 'data:image/png;base64,'

module.exports = {
  set: (values) => {
    const data = {}
    if (values.text != null) {
      data.text = values.text
    }
    if (values.image != null) {
      if (values.image.indexOf(pngDataURLHeader) !== 0) {
        throw new Error('image must be PNG data URL')
      }
      const base64 = values.image.slice(pngDataURLHeader.length)
      data.image = Buffer.from(base64, 'base64')
    }
    if (values.data != null) {
      data.data = values.data
    }
    addon.set(data)
  },

  hasImage: () => addon.hasImage(),
  hasText: () => addon.hasText(),
  hasData: (mimeType) => addon.hasData(mimeType),

  getImage: () => {
    const buffer = addon.getImage()
    return pngDataURLHeader + buffer.toString('base64')
  },
  getText: () => addon.getText(),
  getDataBuffer: (mimeType) => addon.getDataBuffer(mimeType),
  getDataString: (mimeType) => addon.getDataString(mimeType)
}
