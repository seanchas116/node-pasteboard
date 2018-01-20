const fs = require('fs')
const assert = require('assert')
const clipboardy = require('clipboardy')
const PngImg = require('png-img')
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
    const header = 'data:image/png;base64,'
    const pngData = fs.readFileSync('test.png')
    const dataURL = header + pngData.toString('base64')
    pasteboard.set({image: dataURL})
    assert.equal(pasteboard.hasText(), false)
    assert.equal(pasteboard.hasImage(), true)

    let copiedImage = pasteboard.getImage()
    assert.equal(copiedImage.slice(0, header.length), header)
    const copiedPngData = Buffer.from(copiedImage.slice(header.length), 'base64')

    // FIXME: pngjs cannot parse copied image
    const original = new PngImg(pngData)
    const copied = new PngImg(copiedPngData)
    assert.deepEqual(copied.size(), original.size())
    for (let y = 0; y < original.size().height; ++y) {
      for (let x = 0; x < original.size().width; ++x) {
        assert.deepEqual(copied.get(x, y), original.get(x, y))
      }
    }
  })
})
