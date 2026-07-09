import { Questionnaire } from '../model/Questionnaire'
import { Question } from '../model/Question'
import { Answer } from '../model/Answer'
import { QuestionType } from '../model/enums/QuestionType'
import { IdGenerator } from '../common/utils/IdGenerator'
import { MockDataGenerator } from '../common/utils/MockData'

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
  answers: Record<string, string> = {}
  /** 填写开始时间 */
  startTime: number = 0
  /** 是否已提交 */
  submitted: boolean = false

  /** 加载问卷数据 */
  loadQuestionnaire(questionnaireId: string): void {
    this.startTime = Date.now()
    // Stage 3: Mock 数据加载
    const allMock = MockDataGenerator.generateQuestionnaires()
    const found = allMock.find(q => q.id === questionnaireId)
    if (found) {
      this.questionnaire = found
      this.questions = MockDataGenerator.generateQuestions(questionnaireId)
    }
    // 初始化答案
    this.answers = {}
    this.submitted = false
  }

  /** 获取某题的当前答案 */
  getAnswer(questionId: string): string {
    return this.answers[questionId] || ''
  }

  /** 设置某题的答案 */
  setAnswer(questionId: string, value: string): void {
    this.answers[questionId] = value
  }

  /** 计算当前进度 (已完成题数 / 总题数) */
  getProgress(): number {
    const total = this.questions.length
    if (total === 0) return 0
    let completed = 0
    this.questions.forEach(q => {
      const val = this.answers[q.id]
      if (val && val.length > 0) {
        // 多选至少选一个
        if (q.type === QuestionType.MULTI) {
          try {
            const arr = JSON.parse(val) as string[]
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
      const val = this.answers[q.id]
      if (val && val.length > 0) {
        if (q.type === QuestionType.MULTI) {
          try {
            const arr = JSON.parse(val) as string[]
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
  validate(): { valid: boolean; message: string; missingIndex: number } {
    for (let i = 0; i < this.questions.length; i++) {
      const q = this.questions[i]
      if (!q.required) continue
      const val = this.answers[q.id]
      if (!val || val.length === 0) {
        return { valid: false, message: `第${i + 1}题为必答题，请填写`, missingIndex: i }
      }
      // 多选至少选一个
      if (q.type === QuestionType.MULTI) {
        try {
          const arr = JSON.parse(val) as string[]
          if (arr.length === 0) {
            return { valid: false, message: `第${i + 1}题为必答题，请至少选择一个选项`, missingIndex: i }
          }
        } catch (e) {
          return { valid: false, message: `第${i + 1}题为必答题，请至少选择一个选项`, missingIndex: i }
        }
      }
    }
    return { valid: true, message: '', missingIndex: -1 }
  }

  /** 收集最终答案列表 */
  collectAnswers(): Answer[] {
    const result: Answer[] = []
    for (const questionId in this.answers) {
      const answer = new Answer()
      answer.id = IdGenerator.generate()
      answer.questionId = questionId
      answer.value = this.answers[questionId]
      result.push(answer)
    }
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
