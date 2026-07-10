import { User } from '../model/User'
import { IdGenerator } from '../common/utils/IdGenerator'

export class AuthResult {
  success: boolean = false
  message: string = ''
}

/**
 * 认证服务 — 纯内存模式（开发/预览器/模拟器无 Context 依赖）
 * 应用重启后内存清空，需重新登录
 */
export class AuthService {
  private static readonly KEY_USER_ID: string = 'login_user_id'

  /** 用户库 - Map<userId, User> */
  private static memoryUsers: Map<string, User> = new Map()
  /** 持久化登录态 - Map<key, value> */
  private static memoryPrefs: Map<string, string> = new Map()
  /** 当前登录用户 */
  private static currentUser: User | null = null

  /** 初始化 - 同步执行（无 await，避免异常被 .catch 误捕） */
  static init(): void {
    const savedId: string = AuthService.memoryPrefs.get(AuthService.KEY_USER_ID) || ''
    if (savedId) {
      const savedUser: User | undefined = AuthService.memoryUsers.get(savedId)
      if (savedUser) {
        AuthService.currentUser = savedUser
      }
    }
  }

  /** 注册 - 同步版本（最简，无任何 await） */
  static register(username: string, password: string, nickname: string): AuthResult {
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

  /** 登录 - 同步版本 */
  static login(username: string, password: string): AuthResult {
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
    AuthService.memoryPrefs.set(AuthService.KEY_USER_ID, found.id)
    result.success = true
    result.message = '登录成功'
    return result
  }

  /** 自动登录 - 同步 */
  static autoLogin(): User | null {
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
  static logout(): void {
    AuthService.currentUser = null
    AuthService.memoryPrefs.delete(AuthService.KEY_USER_ID)
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
}
