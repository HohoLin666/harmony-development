import { Questionnaire } from '../model/Questionnaire'
import { Question } from '../model/Question'
import { PublishStatus } from '../model/enums/PublishStatus'
import { MockDataGenerator } from '../common/utils/MockData'

/**
 * 本地问卷仓库 - 开发阶段使用内存保存创建的问卷和题目
 */
export class QuestionnaireStore {
  private static initialized: boolean = false
  private static questionnaires: Questionnaire[] = []
  private static questionMap: Map<string, Question[]> = new Map()

  private static ensureInitialized(): void {
    if (QuestionnaireStore.initialized) {
      return
    }
    // 不再生成 Mock 数据，列表初始为空
    QuestionnaireStore.initialized = true
  }

  static getAll(): Questionnaire[] {
    QuestionnaireStore.ensureInitialized()
    return QuestionnaireStore.questionnaires
  }

  static getPublished(): Questionnaire[] {
    QuestionnaireStore.ensureInitialized()
    return QuestionnaireStore.questionnaires.filter((item: Questionnaire) => {
      return item.status === PublishStatus.PUBLISHED
    })
  }

  static getMine(): Questionnaire[] {
    QuestionnaireStore.ensureInitialized()
    return QuestionnaireStore.questionnaires.filter((item: Questionnaire) => {
      return item.creatorName === '我'
    })
  }

  static findQuestionnaire(questionnaireId: string): Questionnaire | null {
    QuestionnaireStore.ensureInitialized()
    const found: Questionnaire | undefined = QuestionnaireStore.questionnaires.find((item: Questionnaire) => {
      return item.id === questionnaireId
    })
    return found || null
  }

  static getQuestions(questionnaireId: string): Question[] {
    QuestionnaireStore.ensureInitialized()
    return QuestionnaireStore.questionMap.get(questionnaireId) || []
  }

  static save(questionnaire: Questionnaire, questions: Question[]): void {
    QuestionnaireStore.ensureInitialized()
    questionnaire.questionCount = questions.length
    questionnaire.updatedAt = Date.now()

    const index: number = QuestionnaireStore.questionnaires.findIndex((item: Questionnaire) => {
      return item.id === questionnaire.id
    })
    if (index >= 0) {
      QuestionnaireStore.questionnaires[index] = questionnaire
    } else {
      QuestionnaireStore.questionnaires.unshift(questionnaire)
    }
    QuestionnaireStore.questionMap.set(questionnaire.id, questions)
  }
}
