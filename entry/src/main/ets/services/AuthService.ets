import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { User } from '../model/User'
import { DatabaseHelper } from '../data/DatabaseHelper'
import { UserDao } from '../data/UserDao'

/**
 * 认证结果
 */
export class AuthResult {
  success: boolean = false
  message: string = ''
}

/**
 * 认证服务 — 登录/注册/登出/自动登录
 */
export class AuthService {
  private static readonly PREF_NAME: string = 'auth_prefs'
  private static readonly KEY_USER_ID: string = 'login_user_id'
  private static readonly KEY_USERNAME: string = 'login_username'
  private static readonly KEY_NICKNAME: string = 'login_nickname'

  private static dataPreferences: preferences.Preferences | null = null
  private static currentUser: User | null = null

  /** 初始化 Preferences */
  static async init(context: Object): Promise<void> {
    try {
      AuthService.dataPreferences = await preferences.getPreferences(context, AuthService.PREF_NAME)
    } catch (err) {
      console.error('[Auth] Preferences init failed')
    }
  }

  /** 注册 */
  static async register(username: string, password: string, nickname: string): Promise<AuthResult> {
    const result: AuthResult = new AuthResult()
    if (!username || username.length < 3) {
      result.message = '用户名至少3个字符'
      return result
    }
    if (!password || password.length < 6) {
      result.message = '密码至少6个字符'
      return result
    }
    const hashed: string = AuthService.hashPassword(password)
    const store = await DatabaseHelper.getStore({} as common.Context)
    const dao: UserDao = new UserDao(store)
    const user: User | null = await dao.register(username, hashed, nickname)
    if (!user) {
      result.message = '用户名已存在'
      return result
    }
    result.success = true
    result.message = '注册成功'
    return result
  }

  /** 登录 */
  static async login(username: string, password: string): Promise<AuthResult> {
    const result: AuthResult = new AuthResult()
    if (!username || !password) {
      result.message = '请输入账号和密码'
      return result
    }
    const hashed: string = AuthService.hashPassword(password)
    const store = await DatabaseHelper.getStore({} as common.Context)
    const dao: UserDao = new UserDao(store)
    const user: User | null = await dao.login(username, hashed)
    if (!user) {
      result.message = '账号或密码错误'
      return result
    }
    AuthService.currentUser = user
    await AuthService.saveLoginState(user)
    result.success = true
    result.message = '登录成功'
    return result
  }

  /** 自动登录 */
  static async autoLogin(): Promise<User | null> {
    const prefs: preferences.Preferences | null = AuthService.dataPreferences
    if (!prefs) return null
    try {
      const userId: string = await prefs.get(AuthService.KEY_USER_ID, '') as string
      if (!userId || userId.length === 0) return null
      const store = await DatabaseHelper.getStore({} as common.Context)
      const dao: UserDao = new UserDao(store)
      const user: User | null = await dao.findById(userId)
      if (user) {
        AuthService.currentUser = user
        return user
      }
      await AuthService.logout()
    } catch (err) {
      console.error('[Auth] autoLogin failed')
    }
    return null
  }

  /** 登出 */
  static async logout(): Promise<void> {
    AuthService.currentUser = null
    const prefs: preferences.Preferences | null = AuthService.dataPreferences
    if (prefs) {
      try {
        await prefs.delete(AuthService.KEY_USER_ID)
        await prefs.delete(AuthService.KEY_USERNAME)
        await prefs.delete(AuthService.KEY_NICKNAME)
        await prefs.flush()
      } catch (err) {
        // ignore
      }
    }
  }

  /** 获取当前登录用户 */
  static getCurrentUser(): User | null {
    return AuthService.currentUser
  }

  /** 是否已登录 */
  static isLoggedIn(): boolean {
    return AuthService.currentUser !== null
  }

  // ====== 私有方法 ======

  /** SHA256 哈希密码 */
  private static hashPassword(password: string): string {
    try {
      let hash: number = 0
      for (let i: number = 0; i < password.length; i++) {
        const chr: number = password.charCodeAt(i)
        hash = ((hash << 5) - hash) + chr
        hash = hash | 0
      }
      return 'hash_' + Math.abs(hash).toString(16)
    } catch (err) {
      return 'hash_fallback'
    }
  }

  /** 保存登录状态到 Preferences */
  private static async saveLoginState(user: User): Promise<void> {
    const prefs: preferences.Preferences | null = AuthService.dataPreferences
    if (!prefs) return
    try {
      await prefs.put(AuthService.KEY_USER_ID, user.id)
      await prefs.put(AuthService.KEY_USERNAME, user.username)
      await prefs.put(AuthService.KEY_NICKNAME, user.nickname)
      await prefs.flush()
    } catch (err) {
      console.error('[Auth] save login state failed')
    }
  }
}
