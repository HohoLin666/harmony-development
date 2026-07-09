/**
 * 题型枚举
 */
export enum QuestionType {
  /** 单选 */
  SINGLE = 'single',
  /** 多选 */
  MULTI = 'multi',
  /** 单行填空 */
  TEXT = 'text',
  /** 多行文本 */
  TEXTAREA = 'textarea',
  /** 评分题 */
  RATE = 'rate',
  /** 矩阵题 */
  MATRIX = 'matrix',
  /** 日期 */
  DATE = 'date',
  /** 数字 */
  NUMBER = 'number'
}

/**
 * 题型中文显示名映射
 */
export const QuestionTypeLabel: Record<string, string> = {
  [QuestionType.SINGLE]: '单选题',
  [QuestionType.MULTI]: '多选题',
  [QuestionType.TEXT]: '填空题',
  [QuestionType.TEXTAREA]: '文本题',
  [QuestionType.RATE]: '评分题',
  [QuestionType.MATRIX]: '矩阵题',
  [QuestionType.DATE]: '日期题',
  [QuestionType.NUMBER]: '数字题'
}
