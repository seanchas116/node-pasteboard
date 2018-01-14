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
  it('sets/gets custom data', () => {
    const type = 'application/x-foo-bar'
    const data = 'Hello, custom data'
    pasteboard.set({
      data: { [type]: data }
    })
    assert.equal(pasteboard.getDataString(type), data)
  })
})
