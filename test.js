const fs = require('fs')
const assert = require('assert')
const clipboardy = require('clipboardy')
const pasteboard = require('.')

describe('pasteboard', () => {
  it('sets text', () => {
    const text = 'Hello, copy'
    pasteboard.set({text})
    assert.equal(pasteboard.hasText(), true)
    assert.equal(clipboardy.readSync(), text)
  })
  it('gets text', () => {
    const text = 'Hello, paste'
    clipboardy.writeSync(text)
    assert.equal(pasteboard.hasText(), true)
    assert.equal(pasteboard.getText(), text)
  })
  it('sets/gets custom data string', () => {
    const type1 = 'application/x-foo-bar'
    const type2 = 'application/x-hoge-poyo'
    const type3 = 'application/x-not-copied'
    const data = 'Hello, custom data'
    pasteboard.set({
      text: data,
      data: { [type1]: data, [type2]: data }
    })
    assert.equal(pasteboard.hasText(), true)
    assert.equal(pasteboard.hasImage(), false)
    assert.equal(pasteboard.hasData(type1), true)
    assert.equal(pasteboard.hasData(type2), true)
    assert.equal(pasteboard.hasData(type3), false)
    assert.equal(clipboardy.readSync(), data)
    assert.equal(pasteboard.getDataString(type1), data)
    assert.equal(pasteboard.getDataString(type2), data)
  })
  it('sets/gets custom data buffer', () => {
    const type1 = 'application/x-foo-bar'
    const type2 = 'application/x-hoge-poyo'
    const type3 = 'application/x-not-copied'
    const data = Buffer.from('Hello, custom data')
    pasteboard.set({
      data: { [type1]: data, [type2]: data }
    })
    assert.equal(pasteboard.hasText(), false)
    assert.equal(pasteboard.hasImage(), false)
    assert.equal(pasteboard.hasData(type1), true)
    assert.equal(pasteboard.hasData(type2), true)
    assert.equal(pasteboard.hasData(type3), false)
    assert.equal(pasteboard.getDataBuffer(type1).toString(), data)
    assert.equal(pasteboard.getDataBuffer(type2).toString(), data)
    assert.equal(pasteboard.getDataBuffer(type3), undefined)
  })
  it('sets/gets image', () => {
    const width = 20
    const height  = 10
    const data = new Buffer(width * height * 4)

    let i = 0
    for (let y = 0; y < height; ++y) {
      for (let x = 0; x < width; ++x) {
        if (x < 10) {
          data[i++] = 255
          data[i++] = 0
          data[i++] = 0
          data[i++] = 255
        } else {
          // unpremultiplied transparent color
          data[i++] = 0
          data[i++] = 255
          data[i++] = 0
          data[i++] = 128
        }
      }
    }

    let image = { width, height, data }
    pasteboard.set({ image })

    let copiedImage = pasteboard.getImage()
    assert.equal(pasteboard.hasImage(), true)
    assert.equal(copiedImage.width, image.width)
    assert.equal(copiedImage.height, image.height)
    assert.deepEqual(copiedImage.data, image.data)
  })
})
