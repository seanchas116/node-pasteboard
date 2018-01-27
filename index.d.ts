interface PasteboardImage {
  width: number
  height: number
  data: Uint8ClampedArray
}

interface PasteboardValues {
  image?: PasteboardImage
  text?: string
  data?: { [type: string]: Buffer }
}

export function set (values: PasteboardValues): void

export function hasImage (): boolean
export function hasText (): boolean
export function hasData (type: string): boolean

export function getImage (): PasteboardImage | undefined
export function getText (): string | undefined
export function getData (type: string): Buffer | undefined
