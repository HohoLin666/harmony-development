import { relationalStore } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

/**
 * 数据库初始化工具
 * 封装关系型数据库的创建和升级逻辑
 *
 * 表结构：
 *  questionnaire (id, title, desc, creator_id, status, q_count, r_count, deadline, share_token, created_at, updated_at)
 *  question (id, q_id, type, title, required, options_json, logic_jump, order_idx)
 *  response (id, q_id, user_id, device_id, duration, submitted_at)
 *  answer (id, resp_id, question_id, value, created_at)
 */
export class DatabaseHelper {
  private static readonly DB_NAME = 'questionnaire.db'
  private static readonly DB_VERSION = 1
  private static rdbStore: relationalStore.RdbStore | null = null

  /** 获取数据库实例（单例） */
  static async getStore(context: common.Context): Promise<relationalStore.RdbStore> {
    if (this.rdbStore) return this.rdbStore

    const config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    this.rdbStore = await relationalStore.getRdbStore(context, config)
    await this.createTables()
    return this.rdbStore
  }

  /** 创建表结构 */
  private static async createTables(): Promise<void> {
    if (!this.rdbStore) return

    const createQuestionnaire = `
      CREATE TABLE IF NOT EXISTS questionnaire (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        creator_id TEXT NOT NULL DEFAULT '',
        creator_name TEXT DEFAULT '',
        status INTEGER DEFAULT 0,
        question_count INTEGER DEFAULT 0,
        response_count INTEGER DEFAULT 0,
        deadline INTEGER,
        share_token TEXT DEFAULT '',
        cover_image TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `

    const createQuestion = `
      CREATE TABLE IF NOT EXISTS question (
        id TEXT PRIMARY KEY,
        questionnaire_id TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'single',
        title TEXT NOT NULL DEFAULT '',
        required INTEGER DEFAULT 0,
        options_json TEXT DEFAULT '[]',
        logic_jump TEXT,
        order_index INTEGER DEFAULT 0,
        max_rate INTEGER DEFAULT 5,
        number_min REAL,
        number_max REAL,
        FOREIGN KEY (questionnaire_id) REFERENCES questionnaire(id)
      )
    `

    const createResponse = `
      CREATE TABLE IF NOT EXISTS response (
        id TEXT PRIMARY KEY,
        questionnaire_id TEXT NOT NULL,
        user_id TEXT NOT NULL DEFAULT '',
        device_id TEXT DEFAULT '',
        duration INTEGER DEFAULT 0,
        submitted_at INTEGER NOT NULL,
        FOREIGN KEY (questionnaire_id) REFERENCES questionnaire(id)
      )
    `

    const createAnswer = `
      CREATE TABLE IF NOT EXISTS answer (
        id TEXT PRIMARY KEY,
        response_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        value TEXT DEFAULT '',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (response_id) REFERENCES response(id),
        FOREIGN KEY (question_id) REFERENCES question(id)
      )
    `

    await this.rdbStore.executeSql(createQuestionnaire)
    await this.rdbStore.executeSql(createQuestion)
    await this.rdbStore.executeSql(createResponse)
    await this.rdbStore.executeSql(createAnswer)
  }

  /** 关闭数据库 */
  static async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close()
      this.rdbStore = null
    }
  }
}
