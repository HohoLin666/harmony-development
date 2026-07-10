import { relationalStore } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

/**
 * 数据库初始化工具
 * 封装关系型数据库的创建和升级逻辑
 */
export class DatabaseHelper {
  private static readonly DB_NAME: string = 'questionnaire.db'
  private static rdbStore: relationalStore.RdbStore | null = null

  /** 获取数据库实例（单例） */
  static async getStore(context: common.Context): Promise<relationalStore.RdbStore> {
    const store: relationalStore.RdbStore | null = DatabaseHelper.rdbStore
    if (store) return store

    const config: relationalStore.StoreConfig = {
      name: DatabaseHelper.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    DatabaseHelper.rdbStore = await relationalStore.getRdbStore(context, config)
    await DatabaseHelper.createTables()
    const result: relationalStore.RdbStore = DatabaseHelper.rdbStore
    return result
  }

  /** 创建表结构 */
  private static async createTables(): Promise<void> {
    const store: relationalStore.RdbStore | null = DatabaseHelper.rdbStore
    if (!store) return

    const createQuestionnaire: string = `CREATE TABLE IF NOT EXISTS questionnaire (id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT DEFAULT '', creator_id TEXT NOT NULL DEFAULT '', creator_name TEXT DEFAULT '', status INTEGER DEFAULT 0, question_count INTEGER DEFAULT 0, response_count INTEGER DEFAULT 0, deadline INTEGER, share_token TEXT DEFAULT '', cover_image TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)`
    const createQuestion: string = `CREATE TABLE IF NOT EXISTS question (id TEXT PRIMARY KEY, questionnaire_id TEXT NOT NULL, type TEXT NOT NULL DEFAULT 'single', title TEXT NOT NULL DEFAULT '', required INTEGER DEFAULT 0, options_json TEXT DEFAULT '[]', logic_jump TEXT, order_index INTEGER DEFAULT 0, max_rate INTEGER DEFAULT 5, number_min REAL, number_max REAL, FOREIGN KEY (questionnaire_id) REFERENCES questionnaire(id))`
    const createResponse: string = `CREATE TABLE IF NOT EXISTS response (id TEXT PRIMARY KEY, questionnaire_id TEXT NOT NULL, user_id TEXT NOT NULL DEFAULT '', device_id TEXT DEFAULT '', duration INTEGER DEFAULT 0, submitted_at INTEGER NOT NULL, FOREIGN KEY (questionnaire_id) REFERENCES questionnaire(id))`
    const createAnswer: string = `CREATE TABLE IF NOT EXISTS answer (id TEXT PRIMARY KEY, response_id TEXT NOT NULL, question_id TEXT NOT NULL, value TEXT DEFAULT '', created_at INTEGER NOT NULL, FOREIGN KEY (response_id) REFERENCES response(id), FOREIGN KEY (question_id) REFERENCES question(id))`
    const createUser: string = `CREATE TABLE IF NOT EXISTS user (id TEXT PRIMARY KEY, username TEXT NOT NULL UNIQUE, password TEXT NOT NULL, nickname TEXT DEFAULT '', avatar TEXT DEFAULT '', phone TEXT DEFAULT '', created_at INTEGER NOT NULL, last_login_at INTEGER DEFAULT 0)`

    await store.executeSql(createQuestionnaire)
    await store.executeSql(createQuestion)
    await store.executeSql(createResponse)
    await store.executeSql(createAnswer)
    await store.executeSql(createUser)
  }

  /** 关闭数据库 */
  static async close(): Promise<void> {
    const store: relationalStore.RdbStore | null = DatabaseHelper.rdbStore
    if (store) {
      await store.close()
      DatabaseHelper.rdbStore = null
    }
  }
}
