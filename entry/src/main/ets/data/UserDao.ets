import { relationalStore } from '@kit.ArkData'
import { User } from '../model/User'
import { IdGenerator } from '../common/utils/IdGenerator'

/**
 * 用户 DAO — 注册、登录、去重查询
 */
export class UserDao {
  private store: relationalStore.RdbStore

  constructor(store: relationalStore.RdbStore) {
    this.store = store
  }

  /** 注册新用户 */
  async register(username: string, hashedPassword: string, nickname: string): Promise<User | null> {
    // 查重
    const exist = await this.findByUsername(username)
    if (exist) return null

    const user = new User()
    user.id = IdGenerator.generate()
    user.username = username
    user.password = hashedPassword
    user.nickname = nickname || username
    user.createdAt = Date.now()
    user.lastLoginAt = Date.now()

    const valueBucket: relationalStore.ValuesBucket = {
      id: user.id,
      username: user.username,
      password: user.password,
      nickname: user.nickname,
      avatar: user.avatar,
      phone: user.phone,
      created_at: user.createdAt,
      last_login_at: user.lastLoginAt
    }

    await this.store.insert('user', valueBucket)
    return user
  }

  /** 登录 — 账号密码校验 */
  async login(username: string, hashedPassword: string): Promise<User | null> {
    const predicates = new relationalStore.RdbPredicates('user')
    predicates.equalTo('username', username)
    predicates.equalTo('password', hashedPassword)

    const resultSet = await this.store.query(predicates)
    if (resultSet.goToFirstRow()) {
      const user = this.rowToUser(resultSet)
      resultSet.close()

      // 更新最后登录时间
      const vb: relationalStore.ValuesBucket = { last_login_at: Date.now() }
      const p = new relationalStore.RdbPredicates('user')
      p.equalTo('id', user.id)
      await this.store.update(vb, p)

      return user
    }
    resultSet.close()
    return null
  }

  /** 按用户名查询 */
  async findByUsername(username: string): Promise<User | null> {
    const predicates = new relationalStore.RdbPredicates('user')
    predicates.equalTo('username', username)
    const resultSet = await this.store.query(predicates)
    if (resultSet.goToFirstRow()) {
      const user = this.rowToUser(resultSet)
      resultSet.close()
      return user
    }
    resultSet.close()
    return null
  }

  /** 按ID查询 */
  async findById(id: string): Promise<User | null> {
    const predicates = new relationalStore.RdbPredicates('user')
    predicates.equalTo('id', id)
    const resultSet = await this.store.query(predicates)
    if (resultSet.goToFirstRow()) {
      const user = this.rowToUser(resultSet)
      resultSet.close()
      return user
    }
    resultSet.close()
    return null
  }

  // ====== 私有方法 ======

  private rowToUser(row: relationalStore.ResultSet): User {
    const user = new User()
    user.id = row.getString(row.getColumnIndex('id'))
    user.username = row.getString(row.getColumnIndex('username'))
    user.password = row.getString(row.getColumnIndex('password'))
    user.nickname = row.getString(row.getColumnIndex('nickname'))
    user.avatar = row.getString(row.getColumnIndex('avatar'))
    user.phone = row.getString(row.getColumnIndex('phone'))
    user.createdAt = row.getLong(row.getColumnIndex('created_at'))
    user.lastLoginAt = row.getLong(row.getColumnIndex('last_login_at'))
    return user
  }
}
