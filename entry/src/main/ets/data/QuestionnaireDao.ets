import { relationalStore } from '@kit.ArkData'
import { DatabaseHelper } from './DatabaseHelper'
import { Questionnaire } from '../model/Questionnaire'
import { PublishStatus } from '../model/enums/PublishStatus'

/**
 * 问卷数据访问对象 — 封装 SQLite CRUD
 */
export class QuestionnaireDao {
  private store: relationalStore.RdbStore

  constructor(store: relationalStore.RdbStore) {
    this.store = store
  }

  /** 插入/更新问卷 */
  async save(questionnaire: Questionnaire): Promise<void> {
    const valueBucket: relationalStore.ValuesBucket = {
      id: questionnaire.id,
      title: questionnaire.title,
      description: questionnaire.description,
      creator_id: questionnaire.creatorId,
      creator_name: questionnaire.creatorName,
      status: this.statusToInt(questionnaire.status),
      question_count: questionnaire.questionCount,
      response_count: questionnaire.responseCount,
      deadline: questionnaire.deadline || null,
      share_token: questionnaire.shareToken,
      cover_image: questionnaire.coverImage || null,
      created_at: questionnaire.createdAt,
      updated_at: questionnaire.updatedAt
    }

    // UPSERT: 先尝试更新
    const predicates = new relationalStore.RdbPredicates('questionnaire')
    predicates.equalTo('id', questionnaire.id)

    const existing = await this.store.query(predicates)
    if (existing.rowCount > 0) {
      existing.close()
      await this.store.update(valueBucket, predicates)
    } else {
      existing.close()
      await this.store.insert('questionnaire', valueBucket)
    }
  }

  /** 查询所有问卷（按更新时间倒序） */
  async findAll(): Promise<Questionnaire[]> {
    const predicates = new relationalStore.RdbPredicates('questionnaire')
    predicates.orderByDesc('updated_at')

    const resultSet = await this.store.query(predicates)
    const list: Questionnaire[] = []

    while (resultSet.goToNextRow()) {
      list.push(this.rowToQuestionnaire(resultSet))
    }
    resultSet.close()
    return list
  }

  /** 按状态查询 */
  async findByStatus(status: PublishStatus): Promise<Questionnaire[]> {
    const predicates = new relationalStore.RdbPredicates('questionnaire')
    predicates.equalTo('status', this.statusToInt(status))
    predicates.orderByDesc('updated_at')

    const resultSet = await this.store.query(predicates)
    const list: Questionnaire[] = []

    while (resultSet.goToNextRow()) {
      list.push(this.rowToQuestionnaire(resultSet))
    }
    resultSet.close()
    return list
  }

  /** 按ID查询 */
  async findById(id: string): Promise<Questionnaire | null> {
    const predicates = new relationalStore.RdbPredicates('questionnaire')
    predicates.equalTo('id', id)

    const resultSet = await this.store.query(predicates)
    if (resultSet.goToFirstRow()) {
      const q = this.rowToQuestionnaire(resultSet)
      resultSet.close()
      return q
    }
    resultSet.close()
    return null
  }

  /** 删除问卷 */
  async delete(id: string): Promise<void> {
    const predicates = new relationalStore.RdbPredicates('questionnaire')
    predicates.equalTo('id', id)
    await this.store.delete(predicates)
  }

  /** 更新回答计数 */
  async incrementResponseCount(id: string): Promise<void> {
    const valueBucket: relationalStore.ValuesBucket = {
      response_count: 1  // 实际业务中应先查出当前值再+1
    }
    const predicates = new relationalStore.RdbPredicates('questionnaire')
    predicates.equalTo('id', id)
    await this.store.update(valueBucket, predicates)
  }

  // ====== 私有方法 ======

  private rowToQuestionnaire(row: relationalStore.ResultSet): Questionnaire {
    const q = new Questionnaire()
    q.id = row.getString(row.getColumnIndex('id'))
    q.title = row.getString(row.getColumnIndex('title'))
    q.description = row.getString(row.getColumnIndex('description'))
    q.creatorId = row.getString(row.getColumnIndex('creator_id'))
    q.creatorName = row.getString(row.getColumnIndex('creator_name'))
    q.status = this.intToStatus(row.getLong(row.getColumnIndex('status')))
    q.questionCount = row.getLong(row.getColumnIndex('question_count'))
    q.responseCount = row.getLong(row.getColumnIndex('response_count'))
    q.deadline = row.getLong(row.getColumnIndex('deadline')) || undefined
    q.shareToken = row.getString(row.getColumnIndex('share_token'))
    q.coverImage = row.getString(row.getColumnIndex('cover_image')) || undefined
    q.createdAt = row.getLong(row.getColumnIndex('created_at'))
    q.updatedAt = row.getLong(row.getColumnIndex('updated_at'))
    return q
  }

  private statusToInt(status: PublishStatus): number {
    switch (status) {
      case PublishStatus.DRAFT: return 0
      case PublishStatus.PUBLISHED: return 1
      case PublishStatus.CLOSED: return 2
      default: return 0
    }
  }

  private intToStatus(value: number): PublishStatus {
    switch (value) {
      case 0: return PublishStatus.DRAFT
      case 1: return PublishStatus.PUBLISHED
      case 2: return PublishStatus.CLOSED
      default: return PublishStatus.DRAFT
    }
  }
}
