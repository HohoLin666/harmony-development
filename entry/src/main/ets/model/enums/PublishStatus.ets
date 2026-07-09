/**
 * 问卷发布状态
 */
export enum PublishStatus {
  /** 草稿 */
  DRAFT = 'draft',
  /** 已发布 */
  PUBLISHED = 'published',
  /** 已关闭 */
  CLOSED = 'closed'
}

const labelMap: Map<string, string> = new Map()
labelMap.set(PublishStatus.DRAFT, '草稿')
labelMap.set(PublishStatus.PUBLISHED, '已发布')
labelMap.set(PublishStatus.CLOSED, '已关闭')
export const PublishStatusLabel: Map<string, string> = labelMap

const colorMap: Map<string, string> = new Map()
colorMap.set(PublishStatus.DRAFT, '#FAAD14')
colorMap.set(PublishStatus.PUBLISHED, '#52C41A')
colorMap.set(PublishStatus.CLOSED, '#999999')
export const PublishStatusColor: Map<string, string> = colorMap
