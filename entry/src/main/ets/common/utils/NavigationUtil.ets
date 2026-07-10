import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'

/**
 * 路由参数
 */
class RouterParams {
  url: string = ''
  params: Record<string, Object> = {}
}

/**
 * 导航工具 — 统一封装 router 操作
 */
export class NavigationUtil {
  /** 跳转页面 */
  static pushUrl(url: string, params?: Record<string, Object>): void {
    try {
      const rp: RouterParams = new RouterParams()
      rp.url = url
      if (params) rp.params = params
      router.pushUrl(rp)
    } catch (err) {
      console.error('[Navigation] pushUrl failed')
    }
  }

  /** 替换当前页面 */
  static replaceUrl(url: string, params?: Record<string, Object>): void {
    try {
      const rp: RouterParams = new RouterParams()
      rp.url = url
      if (params) rp.params = params
      router.replaceUrl(rp)
    } catch (err) {
      console.error('[Navigation] replaceUrl failed')
    }
  }

  /** 返回上一页 */
  static back(): void {
    try {
      router.back()
    } catch (err) {
      console.error('[Navigation] back failed')
    }
  }

  /** 获取路由参数 */
  static getParams(): Record<string, Object> {
    try {
      return router.getParams() as Record<string, Object> || {}
    } catch (err) {
      const empty: Record<string, string> = {}
      return empty
    }
  }

  /** 显示 Toast */
  static showToast(message: string): void {
    try {
      promptAction.showToast({ message: message, duration: 1500 })
    } catch (err) {
      console.error('[Toast] failed')
    }
  }

  /** 显示确认对话框 */
  static showDialog(title: string, message: string, onConfirm: () => void): void {
    try {
      promptAction.showDialog({
        title: title,
        message: message,
        buttons: [
          { text: '取消', color: '#999999' },
          { text: '确认', color: '#1E6FFF' }
        ]
      }).then((result: promptAction.ShowDialogSuccessResponse) => {
        if (result.index === 1) {
          onConfirm()
        }
      })
    } catch (err) {
      console.error('[Dialog] failed')
    }
  }
}
