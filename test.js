const assert = require('assert')
const clipboardy = require('clipboardy')
const pasteboard = require('.')

describe('pasteboard', () => {
  it('copy text', () => {
    const text = 'Hello, pasteboard'
    pasteboard.set({text})
    assert.equal(clipboardy.readSync(), text)
  })
})
