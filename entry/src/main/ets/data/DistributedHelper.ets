import { distributedDataObject } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 分布式数据同步助手
 * 基于 distributedDataObject 实现跨设备问卷数据同步
 *
 * 核心场景：
 * 1. 手机创建问卷 → 平板自动同步问卷列表
 * 2. 手机填写一半 → 平板接力填写（草稿同步）
 * 3. 多设备答题进度实时可见
 *
 * 注意：分布式功能需要多台鸿蒙设备组成超级终端，模拟器不支持
 */
export class DistributedHelper {
  private static session: distributedDataObject.DataObject | null = null
  private static sessionId: string = ''

  /** 创建分布式数据会话 */
  static createSession(questionnaireId: string): void {
    this.sessionId = `quiz_sync_${questionnaireId}`

    try {
      const dataObject = distributedDataObject.create(
        {} as distributedDataObject.DataObject
      )

      // 监听数据变化（远程设备修改时触发）
      dataObject.on('change', (session: string, fields: Array<string>) => {
        console.info(`[分布式] 数据同步: session=${session}, fields=${fields.join(',')}`)
      })

      // 监听状态变化（设备加入/离开）
      dataObject.on('status', (session: string, networkId: string, status: string) => {
        console.info(`[分布式] 状态变化: device=${networkId}, status=${status}`)
        // status: 'online' | 'offline'
      })

      this.session = dataObject
    } catch (err) {
      const error = err as BusinessError
      console.error(`[分布式] 创建会话失败: ${error.message}`)
    }
  }

  /** 写入同步数据 */
  static put(key: string, value: string): void {
    if (!this.session) return
    try {
      this.session[key] = value
      this.session.setSessionId(this.sessionId)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[分布式] 写入失败: ${error.message}`)
    }
  }

  /** 读取同步数据 */
  static get(key: string): string {
    if (!this.session) return ''
    try {
      return this.session[key] as string || ''
    } catch (err) {
      return ''
    }
  }

  /** 退出分布式会话 */
  static destroySession(): void {
    if (this.session) {
      this.session.setSessionId('')
      this.session = null
    }
  }
}
