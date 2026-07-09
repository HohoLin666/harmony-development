import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 导航工具 — 统一封装 router 操作，处理 API 弃用和异常
 */
export class NavigationUtil {
  /** 跳转页面 */
  static pushUrl(url: string, params?: Record<string, Object>): void {
    try {
      router.pushUrl({ url, params })
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
  static getParams(): Record<string, Object> {
    try {
      return router.getParams() as Record<string, Object> || {}
    } catch (err) {
      return {}
    }
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
