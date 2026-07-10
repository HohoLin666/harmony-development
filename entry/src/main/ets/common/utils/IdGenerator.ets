/**
 * ID 生成器 — 生成 UUID v4 格式的唯一标识
 */
export class IdGenerator {
  /** 生成 UUID v4（不使用正则回调，ArkTS 严格模式兼容） */
  static generate(): string {
    const hex: string = '0123456789abcdef'
    const template: string = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    let result: string = ''
    for (let i: number = 0; i < template.length; i++) {
      const ch: string = template.charAt(i)
      if (ch === 'x') {
        const r: number = Math.floor(Math.random() * 16)
        result += hex.charAt(r)
      } else if (ch === 'y') {
        const r: number = (Math.floor(Math.random() * 4) + 8)
        result += hex.charAt(r)
      } else {
        result += ch
      }
    }
    return result
  }

  /** 生成短 ID（8位，用于分享码等场景） */
  static generateShort(): string {
    const chars: string = 'abcdefghijklmnopqrstuvwxyz0123456789'
    let result: string = ''
    for (let i: number = 0; i < 8; i++) {
      const idx: number = Math.floor(Math.random() * chars.length)
      result += chars.charAt(idx)
    }
    return result
  }
}
