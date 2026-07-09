import { PublishStatus } from './enums/PublishStatus'

/**
 * 问卷实体
 */
@Observed
export class Questionnaire {
  id: string = ''
  title: string = ''
  description: string = ''
  creatorId: string = ''
  creatorName: string = ''
  status: PublishStatus = PublishStatus.DRAFT
  questionCount: number = 0
  responseCount: number = 0
  deadline?: number // 截止时间戳(ms)
  shareToken: string = ''
  coverImage?: string // 封面图路径
  createdAt: number = Date.now()
  updatedAt: number = Date.now()

  /** 判断是否已过期 */
  isExpired(): boolean {
    if (!this.deadline) return false
    return Date.now() > this.deadline
  }

  /** 判断是否可以填写 */
  canFill(): boolean {
    return this.status === PublishStatus.PUBLISHED && !this.isExpired()
  }
}
