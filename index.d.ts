interface PasteboardValues {
  image?: string
  text?: string
  data?: { [mimeType: string]: Buffer | string }
}

export function set (values: PasteboardValues)

export function hasImage (): boolean
export function hasText (): boolean
export function hasData (mimeType: string): boolean

export function getImage (): string
export function getText (): string
export function getDataBuffer (mimeType: string): Buffer
export function getDataString (mimeType: string): string
