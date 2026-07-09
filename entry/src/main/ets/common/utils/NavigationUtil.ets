import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 导航工具 — 统一封装 router 操作，处理 API 弃用和异常
 */
export class NavigationUtil {
  /** 跳转页面 */
  static pushUrl(url: string, params?: Map<string, Object>): void {
    try {
      const routerParams: Record<string, Object> = {}
      if (params) {
        params.forEach((value, key) => {
          routerParams[key] = value
        })
      }
      router.pushUrl({ url, params: routerParams })
    } catch (err) {
      const error = err as BusinessError
      console.error(`[Navigation] pushUrl failed: ${error.message}`)
    }
  }

  /** 返回上一页 */
  static back(): void {
    try {
      router.back()
    } catch (err) {
      const error = err as BusinessError
      console.error(`[Navigation] back failed: ${error.message}`)
    }
  }

  /** 获取路由参数 */
  static getParams(): Map<string, Object> {
    const result: Map<string, Object> = new Map()
    try {
      const raw = router.getParams() as Record<string, Object> || {}
      Object.keys(raw).forEach(key => {
        result.set(key, raw[key])
      })
    } catch (err) {
      return new Map()
    }
    return result
  }

  /** 显示 Toast 提示 */
  static showToast(message: string, duration: number = 1500): void {
    try {
      promptAction.showToast({ message, duration })
    } catch (err) {
      console.error(`[Toast] failed: ${message}`)
    }
  }

  /** 显示确认对话框 */
  static showDialog(title: string, message: string, onConfirm: () => void): void {
    AlertDialog.show({
      title: title,
      message: message,
      primaryButton: { value: '确认', action: onConfirm },
      secondaryButton: { value: '取消', action: () => {} }
    })
  }
}
