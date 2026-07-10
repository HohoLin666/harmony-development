import { Questionnaire } from '../model/Questionnaire'
import { Question, Option } from '../model/Question'
import { QuestionType } from '../model/enums/QuestionType'
import { PublishStatus } from '../model/enums/PublishStatus'
import { IdGenerator } from '../common/utils/IdGenerator'
import { QuestionnaireStore } from '../services/QuestionnaireStore'

/**
 * 验证结果
 */
class CheckResult {
  valid: boolean = true
  message: string = ''
}

/**
 * 创建问卷视图模型 — 管理创建/编辑流程
 * Stage 2: 使用内存存储，后续替换为数据库
 */
export class CreateViewModel {
  /** 当前编辑的问卷 */
  questionnaire: Questionnaire = new Questionnaire()
  /** 题目列表 */
  questions: Question[] = []

  /** 是否正在编辑已有问卷 */
  isEditing: boolean = false

  /** 初始化新问卷 */
  initNew(): void {
    this.questionnaire = new Questionnaire()
    this.questionnaire.id = IdGenerator.generate()
    this.questionnaire.creatorId = 'user_001'
    this.questionnaire.creatorName = '我'
    this.questionnaire.status = PublishStatus.DRAFT
    this.questionnaire.shareToken = IdGenerator.generateShort()
    this.questions = []
    this.isEditing = false
  }

  /** 加载已有问卷（编辑模式） */
  loadQuestionnaire(data: Questionnaire, questionList: Question[]): void {
    this.questionnaire = data
    this.questions = questionList
    this.isEditing = true
  }

  /** 添加一道新题目 */
  addQuestion(type: QuestionType): Question {
    const question = new Question()
    question.id = IdGenerator.generate()
    question.questionnaireId = this.questionnaire.id
    question.type = type
    question.title = ''
    question.orderIndex = this.questions.length
    // 单选/多选/矩阵默认添加两个空选项
    if (type === QuestionType.SINGLE || type === QuestionType.MULTI || type === QuestionType.MATRIX) {
      for (let i = 0; i < 2; i++) {
        const opt = new Option()
        opt.id = IdGenerator.generate()
        opt.questionId = question.id
        opt.orderIndex = i
        question.options.push(opt)
      }
    }
    // 评分题默认5分
    if (type === QuestionType.RATE) {
      question.maxRate = 5
    }
    this.questions.push(question)
    return question
  }

  /** 删除一道题目 */
  removeQuestion(index: number): void {
    if (index >= 0 && index < this.questions.length) {
      this.questions.splice(index, 1)
      // 重新编号
      this.questions.forEach((q, i) => {
        q.orderIndex = i
      })
    }
  }

  /** 移动题目位置 */
  moveQuestion(fromIndex: number, toIndex: number): void {
    if (fromIndex === toIndex) return
    if (fromIndex < 0 || toIndex < 0) return
    if (fromIndex >= this.questions.length || toIndex >= this.questions.length) return

    const question = this.questions.splice(fromIndex, 1)[0]
    this.questions.splice(toIndex, 0, question)
    this.questions.forEach((q, i) => {
      q.orderIndex = i
    })
  }

  /** 保存为草稿 */
  saveDraft(): boolean {
    if (!this.questionnaire.title || this.questionnaire.title.trim().length === 0) {
      return false
    }
    this.questionnaire.status = PublishStatus.DRAFT
    this.questionnaire.updatedAt = Date.now()
    this.questionnaire.questionCount = this.questions.length
    QuestionnaireStore.save(this.questionnaire, this.questions)
    return true
  }

  /** 发布问卷 */
  publish(): boolean {
    if (!this.questionnaire.title || this.questionnaire.title.trim().length === 0) {
      return false
    }
    if (this.questions.length === 0) {
      return false
    }
    this.questionnaire.status = PublishStatus.PUBLISHED
    this.questionnaire.updatedAt = Date.now()
    this.questionnaire.questionCount = this.questions.length
    QuestionnaireStore.save(this.questionnaire, this.questions)
    return true
  }

  /** 验证问卷是否有效 */
  validate(): CheckResult {
    if (!this.questionnaire.title || this.questionnaire.title.trim().length === 0) {
      const r = new CheckResult()
      r.valid = false
      r.message = '请输入问卷标题'
      return r
    }
    if (this.questions.length === 0) {
      const r = new CheckResult()
      r.valid = false
      r.message = '请至少添加一道题目'
      return r
    }
    for (let i = 0; i < this.questions.length; i++) {
      const q = this.questions[i]
      if (!q.title || q.title.trim().length === 0) {
        const r = new CheckResult()
        r.valid = false
        r.message = `第${i + 1}题标题不能为空`
        return r
      }
      if (this.needsOptions(q.type) && q.options.length < 2) {
        const r = new CheckResult()
        r.valid = false
        r.message = `第${i + 1}题至少需要2个选项`
        return r
      }
    }
    return new CheckResult()
  }

  private needsOptions(type: QuestionType): boolean {
    return type === QuestionType.SINGLE || type === QuestionType.MULTI || type === QuestionType.MATRIX
  }
}
