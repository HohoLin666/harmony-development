import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { User } from '../model/User'
import { IdGenerator } from '../common/utils/IdGenerator'

export class AuthResult {
  success: boolean = false
  message: string = ''
}

/**
 * 认证服务 — 优先使用数据库，数据库不可用时降级为内存模式
 */
export class AuthService {
  private static readonly PREF_NAME: string = 'auth_prefs'
  private static readonly KEY_USER_ID: string = 'login_user_id'
  private static readonly KEY_USERNAME: string = 'login_username'
  private static readonly KEY_NICKNAME: string = 'login_nickname'

  private static dataPreferences: preferences.Preferences | null = null
  private static currentUser: User | null = null

  /** 内存降级存储（数据库/Preferences不可用时使用） */
  private static memoryUsers: Map<string, User> = new Map()
  private static memoryPrefs: Map<string, string> = new Map()
  private static useMemoryMode: boolean = false

  /** 初始化 */
  static async init(context: Object): Promise<void> {
    try {
      AuthService.dataPreferences = await preferences.getPreferences(context as common.Context, AuthService.PREF_NAME)
    } catch (err) {
      console.info('[Auth] Preferences不可用，启用内存模式')
      AuthService.useMemoryMode = true
    }
    // 尝试从内存恢复上次登录
    const savedId: string = AuthService.memoryPrefs.get(AuthService.KEY_USER_ID) || ''
    if (savedId) {
      const savedUser: User | undefined = AuthService.memoryUsers.get(savedId)
      if (savedUser) {
        AuthService.currentUser = savedUser
      }
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

    // 查重
    const allUsers: User[] = []
    AuthService.memoryUsers.forEach((u: User) => { allUsers.push(u) })
    for (let i: number = 0; i < allUsers.length; i++) {
      if (allUsers[i].username === username) {
        result.message = '用户名已存在'
        return result
      }
    }

    const hashed: string = AuthService.hashPassword(password)
    const user: User = new User()
    user.id = IdGenerator.generate()
    user.username = username
    user.password = hashed
    user.nickname = nickname || username
    user.createdAt = Date.now()
    user.lastLoginAt = Date.now()

    AuthService.memoryUsers.set(user.id, user)
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
    const allUsers: User[] = []
    AuthService.memoryUsers.forEach((u: User) => { allUsers.push(u) })

    let found: User | null = null
    for (let i: number = 0; i < allUsers.length; i++) {
      if (allUsers[i].username === username && allUsers[i].password === hashed) {
        found = allUsers[i]
        found.lastLoginAt = Date.now()
        AuthService.memoryUsers.set(found.id, found)
        break
      }
    }

    if (!found) {
      result.message = '账号或密码错误'
      return result
    }

    AuthService.currentUser = found
    await AuthService.saveLoginState(found)
    result.success = true
    result.message = '登录成功'
    return result
  }

  /** 自动登录 */
  static async autoLogin(): Promise<User | null> {
    // 先从 Preferences 尝试
    if (AuthService.dataPreferences) {
      try {
        const userId: string = await AuthService.dataPreferences.get(AuthService.KEY_USER_ID, '') as string
        if (userId && AuthService.memoryUsers.has(userId)) {
          const user: User | undefined = AuthService.memoryUsers.get(userId)
          if (user) {
            AuthService.currentUser = user
            return user
          }
        }
      } catch (err) {
        // fallback
      }
    }
    // 从内存恢复
    const savedId: string = AuthService.memoryPrefs.get(AuthService.KEY_USER_ID) || ''
    if (savedId && AuthService.memoryUsers.has(savedId)) {
      const user: User | undefined = AuthService.memoryUsers.get(savedId)
      if (user) {
        AuthService.currentUser = user
        return user
      }
    }
    return null
  }

  /** 登出 */
  static async logout(): Promise<void> {
    AuthService.currentUser = null
    AuthService.memoryPrefs.delete(AuthService.KEY_USER_ID)
    if (AuthService.dataPreferences) {
      try {
        await AuthService.dataPreferences.delete(AuthService.KEY_USER_ID)
        await AuthService.dataPreferences.flush()
      } catch (err) {
        // ignore
      }
    }
  }

  static getCurrentUser(): User | null {
    return AuthService.currentUser
  }

  static isLoggedIn(): boolean {
    return AuthService.currentUser !== null
  }

  private static hashPassword(password: string): string {
    let hash: number = 0
    for (let i: number = 0; i < password.length; i++) {
      const chr: number = password.charCodeAt(i)
      hash = ((hash << 5) - hash) + chr
      hash = hash | 0
    }
    return 'hash_' + Math.abs(hash).toString(16)
  }

  private static async saveLoginState(user: User): Promise<void> {
    AuthService.memoryPrefs.set(AuthService.KEY_USER_ID, user.id)
    if (AuthService.dataPreferences) {
      try {
        await AuthService.dataPreferences.put(AuthService.KEY_USER_ID, user.id)
        await AuthService.dataPreferences.flush()
      } catch (err) {
        // ignore
      }
    }
  }
}
