import { QuestionType } from './enums/QuestionType'

/**
 * 选项 — 需要 @Observed 以支持 @Link 双向绑定
 */
@Observed
export class Option {
  id: string = ''
  questionId: string = ''
  text: string = ''
  orderIndex: number = 0
  isCustom: boolean = false
}

/**
 * 逻辑跳转配置
 */
export class LogicJump {
  /** 生效条件：选中哪个选项后触发 */
  triggerOptionId: string = ''
  /** 跳转动作 */
  action: LogicJumpAction = LogicJumpAction.SHOW
  /** 目标题目ID列表 */
  targetQuestionIds: string[] = []
}

export enum LogicJumpAction {
  /** 显示目标题目 */
  SHOW = 'show',
  /** 隐藏目标题目 */
  HIDE = 'hide',
  /** 跳转到目标题目 */
  SKIP = 'skip'
}

/**
 * 题目实体 — 需要 @Observed 以支持 @Link/@ObjectLink 双向绑定
 */
@Observed
export class Question {
  id: string = ''
  questionnaireId: string = ''
  type: QuestionType = QuestionType.SINGLE
  title: string = ''
  required: boolean = false
  options: Option[] = []
  logicJump?: LogicJump
  orderIndex: number = 0
  /** 评分题的最大分值 */
  maxRate?: number
  /** 数字题的校验范围 */
  numberMin?: number
  numberMax?: number
}
