import { User } from '../model/User'

export class AuthResult {
  success: boolean = false
  message: string = ''
}

/**
 * 认证服务 — 纯内存模式（开发/预览器/模拟器无 Context 依赖）
 * 应用重启后内存清空，需重新登录
 */
export class AuthService {
  /** 本地开发用户库，后期接服务器时只需要替换 AuthService 内部实现 */
  private static memoryUsers: User[] = []
  /** 当前登录用户 */
  private static currentUser: User | null = null

  /** 初始化 - 本地内存模式无需异步依赖 */
  static init(): void {
  }

  /** 注册 - 本地同步版本，不访问网络和数据库 */
  static register(username: string, password: string, nickname: string): AuthResult {
    const result: AuthResult = new AuthResult()
    try {
      if (!username || username.length < 3) {
        result.message = '用户名至少3个字符'
        return result
      }
      if (!password || password.length < 6) {
        result.message = '密码至少6个字符'
        return result
      }

      for (let i: number = 0; i < AuthService.memoryUsers.length; i++) {
        if (AuthService.memoryUsers[i].username === username) {
          result.message = '用户名已存在'
          return result
        }
      }

      const now: number = Date.now()
      const user: User = new User()
      user.id = 'local_' + now.toString()
      user.username = username
      user.password = AuthService.hashPassword(password)
      user.nickname = nickname || username
      user.createdAt = now
      user.lastLoginAt = now

      AuthService.memoryUsers.push(user)
      result.success = true
      result.message = '注册成功'
    } catch (err) {
      result.success = false
      result.message = '注册失败，请重试'
    }
    return result
  }

  /** 登录 - 本地同步版本 */
  static login(username: string, password: string): AuthResult {
    const result: AuthResult = new AuthResult()
    if (!username || !password) {
      result.message = '请输入账号和密码'
      return result
    }

    const hashed: string = AuthService.hashPassword(password)
    let found: User | null = null
    for (let i: number = 0; i < AuthService.memoryUsers.length; i++) {
      if (AuthService.memoryUsers[i].username === username && AuthService.memoryUsers[i].password === hashed) {
        found = AuthService.memoryUsers[i]
        found.lastLoginAt = Date.now()
        AuthService.memoryUsers[i] = found
        break
      }
    }

    if (!found) {
      result.message = '账号或密码错误'
      return result
    }

    AuthService.currentUser = found
    result.success = true
    result.message = '登录成功'
    return result
  }

  /** 自动登录 - 同步 */
  static autoLogin(): User | null {
    return AuthService.currentUser
  }

  /** 登出 */
  static logout(): void {
    AuthService.currentUser = null
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
