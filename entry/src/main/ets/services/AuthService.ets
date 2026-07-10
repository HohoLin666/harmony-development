import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { User } from '../model/User'
import { DatabaseHelper } from '../data/DatabaseHelper'
import { UserDao } from '../data/UserDao'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 认证服务 — 登录/注册/登出/自动登录
 * token = 用户ID，存 Preferences 实现持久化登录态
 */
export class AuthService {
  private static readonly PREF_NAME = 'auth_prefs'
  private static readonly KEY_USER_ID = 'login_user_id'
  private static readonly KEY_USERNAME = 'login_username'
  private static readonly KEY_NICKNAME = 'login_nickname'

  private static dataPreferences: preferences.Preferences | null = null
  private static currentUser: User | null = null

  /** 初始化 Preferences */
  static async init(context: common.Context): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(context, this.PREF_NAME)
    } catch (err) {
      console.error('[Auth] Preferences 初始化失败')
    }
  }

  /** 注册 */
  static async register(username: string, password: string, nickname: string): Promise<{ success: boolean; message: string }> {
    if (!username || username.length < 3) return { success: false, message: '用户名至少3个字符' }
    if (!password || password.length < 6) return { success: false, message: '密码至少6个字符' }

    const hashed = AuthService.hashPassword(password)
    const store = await DatabaseHelper.getStore({} as common.Context)
    const dao = new UserDao(store)
    const user = await dao.register(username, hashed, nickname)

    if (!user) return { success: false, message: '用户名已存在' }
    return { success: true, message: '注册成功' }
  }

  /** 登录 */
  static async login(username: string, password: string): Promise<{ success: boolean; message: string }> {
    if (!username || !password) return { success: false, message: '请输入账号和密码' }

    const hashed = AuthService.hashPassword(password)
    const store = await DatabaseHelper.getStore({} as common.Context)
    const dao = new UserDao(store)
    const user = await dao.login(username, hashed)

    if (!user) return { success: false, message: '账号或密码错误' }

    this.currentUser = user
    // 持久化登录态
    await this.saveLoginState(user)
    return { success: true, message: '登录成功' }
  }

  /** 自动登录 — 检查 Preferences 中是否有保存的登录信息 */
  static async autoLogin(): Promise<User | null> {
    if (!this.dataPreferences) return null
    try {
      const userId: string = await this.dataPreferences.get(this.KEY_USER_ID, '') as string
      if (!userId) return null

      const store = await DatabaseHelper.getStore({} as common.Context)
      const dao = new UserDao(store)
      const user = await dao.findById(userId)
      if (user) {
        this.currentUser = user
        return user
      }
      // 用户已不存在，清除无效登录态
      await this.logout()
    } catch (err) {
      console.error('[Auth] 自动登录失败')
    }
    return null
  }

  /** 登出 */
  static async logout(): Promise<void> {
    this.currentUser = null
    if (this.dataPreferences) {
      try {
        await this.dataPreferences.delete(this.KEY_USER_ID)
        await this.dataPreferences.delete(this.KEY_USERNAME)
        await this.dataPreferences.delete(this.KEY_NICKNAME)
        await this.dataPreferences.flush()
      } catch (err) {
        // ignore
      }
    }
  }

  /** 获取当前登录用户 */
  static getCurrentUser(): User | null {
    return this.currentUser
  }

  /** 是否已登录 */
  static isLoggedIn(): boolean {
    return this.currentUser !== null
  }

  // ====== 私有方法 ======

  /** SHA256 哈希密码 */
  private static hashPassword(password: string): string {
    try {
      const md = cryptoFramework.createMd('SHA256')
      const input: cryptoFramework.DataBlob = { data: new Uint8Array(this.stringToUint8Array(password)) }
      md.updateSync(input)
      const result = md.digestSync()
      return this.uint8ArrayToHex(result.data)
    } catch (err) {
      // 降级方案：简单哈希
      let hash = 0
      for (let i = 0; i < password.length; i++) {
        const chr = password.charCodeAt(i)
        hash = ((hash << 5) - hash) + chr
        hash |= 0
      }
      return 'hash_' + Math.abs(hash).toString(16)
    }
  }

  private static stringToUint8Array(str: string): number[] {
    const arr: number[] = []
    for (let i = 0; i < str.length; i++) {
      arr.push(str.charCodeAt(i) & 0xFF)
    }
    return arr
  }

  private static uint8ArrayToHex(data: Uint8Array): string {
    let hex = ''
    for (let i = 0; i < data.length; i++) {
      const h = data[i].toString(16).padStart(2, '0')
      hex += h
    }
    return hex
  }

  /** 保存登录状态到 Preferences */
  private static async saveLoginState(user: User): Promise<void> {
    if (!this.dataPreferences) return
    try {
      await this.dataPreferences.put(this.KEY_USER_ID, user.id)
      await this.dataPreferences.put(this.KEY_USERNAME, user.username)
      await this.dataPreferences.put(this.KEY_NICKNAME, user.nickname)
      await this.dataPreferences.flush()
    } catch (err) {
      console.error('[Auth] 保存登录状态失败')
    }
  }
}
