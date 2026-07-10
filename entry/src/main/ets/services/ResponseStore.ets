import { Questionnaire } from '../model/Questionnaire'

/**
 * 参与记录 — 记录用户填过的问卷
 */
export class ParticipationRecord {
  questionnaireId: string = ''
  questionnaireTitle: string = ''
  submittedAt: number = 0
  questionCount: number = 0
  /** 答案：questionId → answerValue（单选=optionId，多选=JSON数组，文本=原文，评分=数字字符串） */
  answers: Record<string, string> = {}
}

/**
 * 参与记录仓库 — 内存存储用户填过的问卷和答案
 */
export class ResponseStore {
  private static records: ParticipationRecord[] = []

  /** 保存一条参与记录（含答案） */
  static save(questionnaire: Questionnaire, questionCount: number, answers: Record<string, string>): void {
    const record: ParticipationRecord = new ParticipationRecord()
    record.questionnaireId = questionnaire.id
    record.questionnaireTitle = questionnaire.title || '未命名问卷'
    record.submittedAt = Date.now()
    record.questionCount = questionCount
    record.answers = answers
    ResponseStore.records.unshift(record)
  }

  /** 获取所有参与记录 */
  static getAll(): ParticipationRecord[] {
    return ResponseStore.records
  }

  /** 获取某份问卷的所有提交记录 */
  static getByQuestionnaire(questionnaireId: string): ParticipationRecord[] {
    const result: ParticipationRecord[] = []
    for (let i: number = 0; i < ResponseStore.records.length; i++) {
      if (ResponseStore.records[i].questionnaireId === questionnaireId) {
        result.push(ResponseStore.records[i])
      }
    }
    return result
  }

  /** 获取某份问卷的提交数量 */
  static getCountByQuestionnaire(questionnaireId: string): number {
    let count: number = 0
    for (let i: number = 0; i < ResponseStore.records.length; i++) {
      if (ResponseStore.records[i].questionnaireId === questionnaireId) {
        count++
      }
    }
    return count
  }

  /** 获取参与数量 */
  static getCount(): number {
    return ResponseStore.records.length
  }
}
