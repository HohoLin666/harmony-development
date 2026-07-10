import { Questionnaire } from '../model/Questionnaire'

/**
 * 参与记录 — 记录用户填过的问卷
 */
export class ParticipationRecord {
  questionnaireId: string = ''
  questionnaireTitle: string = ''
  submittedAt: number = 0
  questionCount: number = 0
}

/**
 * 参与记录仓库 — 内存存储用户填过的问卷
 */
export class ResponseStore {
  private static records: ParticipationRecord[] = []

  /** 保存一条参与记录 */
  static save(questionnaire: Questionnaire, questionCount: number): void {
    // 去重：同一问卷只保留最新一次
    ResponseStore.records = ResponseStore.records.filter((r: ParticipationRecord) => {
      return r.questionnaireId !== questionnaire.id
    })
    const record: ParticipationRecord = new ParticipationRecord()
    record.questionnaireId = questionnaire.id
    record.questionnaireTitle = questionnaire.title || '未命名问卷'
    record.submittedAt = Date.now()
    record.questionCount = questionCount
    ResponseStore.records.unshift(record)
  }

  /** 获取所有参与记录 */
  static getAll(): ParticipationRecord[] {
    return ResponseStore.records
  }

  /** 获取参与数量 */
  static getCount(): number {
    return ResponseStore.records.length
  }
}
