import { notificationManager } from '@kit.NotificationKit'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 通知服务 — 消息推送提醒
 *
 * 场景：
 * 1. 问卷截止提醒
 * 2. 新回复通知
 * 3. 协同填写邀请
 */
export class NotificationService {
  /**
   * 发送本地通知
   * @param title 通知标题
   * @param text 通知内容
   */
  static sendNotification(title: string, text: string): void {
    try {
      const request: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        }
      }

      notificationManager.publish(request)
        .then(() => {
          console.info(`[通知] 已发送: ${title}`)
        })
        .catch((err: BusinessError) => {
          console.error(`[通知] 发送失败: ${err.message}`)
        })
    } catch (err) {
      console.error(`[通知] 发送异常`)
    }
  }

  /** 问卷收到新回复通知 */
  static notifyNewResponse(questionnaireTitle: string, count: number): void {
    this.sendNotification(
      '新的问卷回复',
      `《${questionnaireTitle}》收到 ${count} 条新回复`
    )
  }

  /** 问卷截止提醒 */
  static notifyDeadline(questionnaireTitle: string): void {
    this.sendNotification(
      '问卷即将截止',
      `《${questionnaireTitle}》将在明天截止，请尽快填写`
    )
  }

  /** 协同填写邀请 */
  static notifyCollaboration(deviceName: string): void {
    this.sendNotification(
      '协同填写邀请',
      `${deviceName} 邀请你一起填写问卷`
    )
  }
}
