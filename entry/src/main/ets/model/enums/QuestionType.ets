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
const labelMap: Map<string, string> = new Map()
labelMap.set(QuestionType.SINGLE, '单选题')
labelMap.set(QuestionType.MULTI, '多选题')
labelMap.set(QuestionType.TEXT, '填空题')
labelMap.set(QuestionType.TEXTAREA, '文本题')
labelMap.set(QuestionType.RATE, '评分题')
labelMap.set(QuestionType.MATRIX, '矩阵题')
labelMap.set(QuestionType.DATE, '日期题')
labelMap.set(QuestionType.NUMBER, '数字题')
export const QuestionTypeLabel: Map<string, string> = labelMap
