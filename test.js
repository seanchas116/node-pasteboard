const fs = require('fs')
const assert = require('assert')
const clipboardy = require('clipboardy')
const {PNG} = require('pngjs');
const pasteboard = require('.')

describe('pasteboard', () => {
  it('sets text', () => {
    const text = 'Hello, copy'
    pasteboard.set({text})
    assert.equal(clipboardy.readSync(), text)
  })
  it('gets text', () => {
    const text = 'Hello, paste'
    clipboardy.writeSync(text)
    assert.equal(pasteboard.getText(), text)
  })
  it('sets/gets custom data string', () => {
    const type1 = 'application/x-foo-bar'
    const type2 = 'application/x-hoge-poyo'
    const data = 'Hello, custom data'
    pasteboard.set({
      text: data,
      data: { [type1]: data, [type2]: data }
    })
    assert.equal(clipboardy.readSync(), data)
    assert.equal(pasteboard.getDataString(type1), data)
    assert.equal(pasteboard.getDataString(type2), data)
  })
  it('sets/gets custom data buffer', () => {
    const type1 = 'application/x-foo-bar'
    const type2 = 'application/x-hoge-poyo'
    const data = Buffer.from('Hello, custom data')
    pasteboard.set({
      data: { [type1]: data, [type2]: data }
    })
    assert.equal(pasteboard.getDataBuffer(type1).toString(), data)
    assert.equal(pasteboard.getDataBuffer(type2).toString(), data)
  })
  it('sets/gets image', () => {
    const header = 'data:image/png;base64,'
    const pngData = fs.readFileSync('test.png')
    const dataURL = header + pngData.toString('base64')
    pasteboard.set({image: dataURL})

    let copiedImage = pasteboard.getImage()
    assert.equal(copiedImage.slice(0, header.length), header)
    const copiedPngData = Buffer.from(copiedImage.slice(header.length), 'base64')

    const original = PNG.sync.read(pngData)
    const copied = PNG.sync.read(copiedPngData) // FIXME: Parsing copiedPngData crashes
    assert.deepEqual(copied.data, original.data)
  })
})
