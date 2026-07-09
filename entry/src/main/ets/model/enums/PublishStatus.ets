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

export const PublishStatusLabel: Record<string, string> = {
  [PublishStatus.DRAFT]: '草稿',
  [PublishStatus.PUBLISHED]: '已发布',
  [PublishStatus.CLOSED]: '已关闭'
}

export const PublishStatusColor: Record<string, string> = {
  [PublishStatus.DRAFT]: '#FAAD14',
  [PublishStatus.PUBLISHED]: '#52C41A',
  [PublishStatus.CLOSED]: '#999999'
}
