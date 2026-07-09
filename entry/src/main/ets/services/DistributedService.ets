import { DistributedHelper } from '../data/DistributedHelper'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 分布式协同服务 — 封装多设备协同的业务逻辑
 *
 * 鸿蒙分布式三大核心能力在本项目中的应用：
 *
 * 1. 分布式数据对象 (distributedDataObject)
 *    → 跨设备同步问卷列表、答题进度、草稿
 *
 * 2. 分布式软总线 (softBus)
 *    → 设备发现与组网：手机和平板自动发现并建立连接
 *
 * 3. 分布式任务调度 (continuation)
 *    → 接力填写：手机填一半，平板无缝继续
 *
 * 使用前提：
 * - 多台鸿蒙设备登录同一华为账号
 * - 设备在同一WiFi网络下
 * - 蓝牙已开启（用于设备发现）
 */
export class DistributedService {
  private static isConnected: boolean = false
  private static connectedDevices: string[] = []

  /**
   * 开始协同填写
   * 为指定问卷创建分布式数据会话，允许其他设备加入填写
   */
  static startCollaboration(questionnaireId: string): void {
    try {
      DistributedHelper.createSession(questionnaireId)
      DistributedHelper.put('status', 'open')
      DistributedHelper.put('questionnaireId', questionnaireId)
      this.isConnected = true
      console.info(`[协同] 已开启协同填写: ${questionnaireId}`)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[协同] 启动失败: ${error.message}`)
    }
  }

  /**
   * 同步答题进度
   * 将当前设备上的答题进度同步到其他设备
   */
  static syncProgress(completedCount: number, totalCount: number): void {
    if (!this.isConnected) return
    DistributedHelper.put('completedCount', String(completedCount))
    DistributedHelper.put('totalCount', String(totalCount))
    DistributedHelper.put('progress', String(Math.round(completedCount / totalCount * 100)))
  }

  /**
   * 获取协同会话中的答题进度
   */
  static getProgress(): { completedCount: number; totalCount: number; progress: number } {
    const completed = parseInt(DistributedHelper.get('completedCount')) || 0
    const total = parseInt(DistributedHelper.get('totalCount')) || 0
    const progress = parseInt(DistributedHelper.get('progress')) || 0
    return { completedCount: completed, totalCount: total, progress }
  }

  /**
   * 结束协同填写
   */
  static endCollaboration(): void {
    DistributedHelper.put('status', 'closed')
    DistributedHelper.destroySession()
    this.isConnected = false
    console.info('[协同] 已结束协同填写')
  }

  /** 检查是否在协同模式 */
  static isCollaborating(): boolean {
    return this.isConnected
  }
}
