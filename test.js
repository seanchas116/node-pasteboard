const fs = require('fs')
const assert = require('assert')
const clipboardy = require('clipboardy')
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
    const png = fs.readFileSync('test.png')
    const dataURL = 'data:image/png;base64,' + png.toString('base64')
    pasteboard.set({image: dataURL})

    let copiedImage = pasteboard.getImage()
    // TODO: check if the image is same
  })
})
