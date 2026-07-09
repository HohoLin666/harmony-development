import { relationalStore } from '@kit.ArkData'
import { Answer } from '../model/Answer'

/**
 * 答案数据访问对象
 */
export class AnswerDao {
  private store: relationalStore.RdbStore

  constructor(store: relationalStore.RdbStore) {
    this.store = store
  }

  /** 批量插入答案 */
  async batchInsert(answers: Answer[], responseId: string): Promise<void> {
    for (const answer of answers) {
      const valueBucket: relationalStore.ValuesBucket = {
        id: answer.id,
        response_id: responseId,
        question_id: answer.questionId,
        value: answer.value,
        created_at: answer.createdAt
      }
      await this.store.insert('answer', valueBucket)
    }
  }

  /** 统计某题的选项分布 (单选/多选) */
  async getOptionCounts(questionId: string): Promise<Record<string, number>> {
    const predicates = new relationalStore.RdbPredicates('answer')
    predicates.equalTo('question_id', questionId)

    const resultSet = await this.store.query(predicates)
    const counts: Record<string, number> = {}

    while (resultSet.goToNextRow()) {
      const value = resultSet.getString(resultSet.getColumnIndex('value'))
      // 单选：value = optionId
      // 多选：value = ["opt1","opt2"]，需要解析
      try {
        const arr = JSON.parse(value) as string[]
        arr.forEach(id => {
          counts[id] = (counts[id] || 0) + 1
        })
      } catch (e) {
        counts[value] = (counts[value] || 0) + 1
      }
    }
    resultSet.close()
    return counts
  }

  /** 统计某题的总回答数 */
  async getAnswerCount(questionId: string): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('answer')
    predicates.equalTo('question_id', questionId)
    const resultSet = await this.store.query(predicates)
    const count = resultSet.rowCount
    resultSet.close()
    return count
  }
}
