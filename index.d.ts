interface PasteboardImage {
  width: number
  height: number
  data: Uint8ClampedArray
}

interface PasteboardValues {
  image?: PasteboardImage
  text?: string
  data?: { [mimeType: string]: Buffer | string }
}

export function set (values: PasteboardValues)

export function hasImage (): boolean
export function hasText (): boolean
export function hasData (mimeType: string): boolean

export function getImage (): PasteboardImage
export function getText (): string
export function getDataBuffer (mimeType: string): Buffer
export function getDataString (mimeType: string): string
