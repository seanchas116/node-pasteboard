interface PasteboardValues {
  image?: string
  text?: string
  data?: { [type: string]: Buffer }
}

export function set (values: PasteboardValues)

export function hasImage (): boolean
export function hasText (): boolean
export function hasData (type: string): boolean

export function getImage (): string
export function getText (): string
export function getData (type: string): Buffer
