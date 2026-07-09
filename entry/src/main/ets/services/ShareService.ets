import { systemShare } from '@kit.ShareKit'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileUri } from '@kit.CoreFileKit'

/**
 * 分享服务 — 通过系统分享面板将问卷分享到微信/QQ/短信等
 *
 * 核心场景：
 * 1. 创建完成后一键分享问卷链接
 * 2. 分享卡片包含标题和描述
 */
export class ShareService {
  private context: common.UIAbilityContext

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  /**
   * 分享文本（问卷链接）
   * @param title 分享标题
   * @param content 分享内容（问卷链接）
   */
  shareText(title: string, content: string): void {
    const shareData = new systemShare.ShareData({
      uniformData: {
        plainText: {
          textContent: `${title}\n\n${content}`
        }
      },
      options: {
        isExcluded: false
      }
    })

    try {
      const controller = new systemShare.ShareController(shareData)
      controller.show(this.context)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[分享] 调用失败: ${error.message}`)
    }
  }

  /**
   * 分享问卷预览图
   * @param title 标题
   * @param imagePath 图片路径
   */
  shareImage(title: string, imagePath: string): void {
    try {
      const uri = fileUri.getUriFromPath(imagePath)

      const shareData = new systemShare.ShareData({
        uniformData: {
          images: [{
            uri: uri,
            description: title
          }]
        }
      })

      const controller = new systemShare.ShareController(shareData)
      controller.show(this.context)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[分享] 图片分享失败: ${error.message}`)
    }
  }

  /** 生成问卷链接 */
  static generateShareLink(shareToken: string): string {
    return `harmony://questionnaire/share/${shareToken}`
  }
}
