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

export function set (values: PasteboardValues): void

export function hasImage (): boolean
export function hasText (): boolean
export function hasData (mimeType: string): boolean

export function getImage (): PasteboardImage | undefined
export function getText (): string | undefined
export function getDataBuffer (mimeType: string): Buffer | undefined
export function getDataString (mimeType: string): string | undefined
