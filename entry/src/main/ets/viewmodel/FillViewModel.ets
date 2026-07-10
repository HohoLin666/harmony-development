import { Questionnaire } from '../model/Questionnaire'
import { Question } from '../model/Question'
import { Answer } from '../model/Answer'
import { QuestionType } from '../model/enums/QuestionType'
import { IdGenerator } from '../common/utils/IdGenerator'
import { QuestionnaireStore } from '../services/QuestionnaireStore'

/**
 * 验证结果
 */
export class ValidationResult {
  valid: boolean = true
  message: string = ''
  missingIndex: number = -1
}

/**
 * 填写视图模型 — 管理问卷填写流程
 * Stage 3: 先用 Mock 数据，后续改为数据库加载
 */
export class FillViewModel {
  /** 当前问卷 */
  questionnaire: Questionnaire = new Questionnaire()
  /** 题目列表 */
  questions: Question[] = []
  /** 每题对应的答案值 (questionId → value) */
  answers: Map<string, string> = new Map()
  /** 填写开始时间 */
  startTime: number = 0
  /** 是否已提交 */
  submitted: boolean = false

  /** 加载问卷数据 */
  loadQuestionnaire(questionnaireId: string): void {
    this.startTime = Date.now()
    const found: Questionnaire | null = QuestionnaireStore.findQuestionnaire(questionnaireId)
    if (found) {
      this.questionnaire = found
      this.questions = QuestionnaireStore.getQuestions(questionnaireId)
    }
    // 初始化答案
    this.answers = new Map()
    this.submitted = false
  }

  /** 获取某题的当前答案 */
  getAnswer(questionId: string): string {
    const val = this.answers.get(questionId)
    return val || ''
  }

  /** 设置某题的答案 */
  setAnswer(questionId: string, value: string): void {
    this.answers.set(questionId, value)
  }

  /** 计算当前进度 (已完成题数 / 总题数) */
  getProgress(): number {
    const total = this.questions.length
    if (total === 0) return 0
    let completed = 0
    this.questions.forEach(q => {
      const val = this.answers.get(q.id)
      if (val && val.length > 0) {
        // 多选至少选一个
        if (q.type === QuestionType.MULTI) {
          try {
            const arr: string[] = JSON.parse(val)
            if (arr.length > 0) completed++
          } catch (e) { /* ignore */ }
        } else {
          completed++
        }
      }
    })
    return Math.round(completed / total * 100)
  }

  /** 获取已完成的题目数 */
  getCompletedCount(): number {
    let count = 0
    this.questions.forEach(q => {
      const val = this.answers.get(q.id)
      if (val && val.length > 0) {
        if (q.type === QuestionType.MULTI) {
          try {
            const arr: string[] = JSON.parse(val)
            if (arr.length > 0) count++
          } catch (e) { /* ignore */ }
        } else {
          count++
        }
      }
    })
    return count
  }

  /** 验证：是否所有必答题都已填写 */
  validate(): ValidationResult {
    for (let i = 0; i < this.questions.length; i++) {
      const q = this.questions[i]
      if (!q.required) continue
      const val = this.answers.get(q.id)
      if (!val || val.length === 0) {
        const r = new ValidationResult()
        r.valid = false
        r.message = `第${i + 1}题为必答题，请填写`
        r.missingIndex = i
        return r
      }
      // 多选至少选一个
      if (q.type === QuestionType.MULTI) {
        try {
          const arr: string[] = JSON.parse(val)
          if (arr.length === 0) {
            const r = new ValidationResult()
            r.valid = false
            r.message = `第${i + 1}题为必答题，请至少选择一个选项`
            r.missingIndex = i
            return r
          }
        } catch (e) {
          const r = new ValidationResult()
          r.valid = false
          r.message = `第${i + 1}题为必答题，请至少选择一个选项`
          r.missingIndex = i
          return r
        }
      }
    }
    return new ValidationResult()
  }

  /** 收集最终答案列表 */
  collectAnswers(): Answer[] {
    const result: Answer[] = []
    this.answers.forEach((value, questionId) => {
      const answer = new Answer()
      answer.id = IdGenerator.generate()
      answer.questionId = questionId
      answer.value = value
      result.push(answer)
    })
    return result
  }

  /** 提交问卷 */
  submit(): boolean {
    if (this.submitted) return false
    const validation = this.validate()
    if (!validation.valid) return false
    this.submitted = true
    return true
  }
}
