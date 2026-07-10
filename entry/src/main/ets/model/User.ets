/**
 * 用户实体
 */
@Observed
export class User {
  id: string = ''
  username: string = ''
  password: string = ''   // 存储 SHA256 哈希值
  nickname: string = ''
  avatar: string = ''
  phone: string = ''
  createdAt: number = 0
  lastLoginAt: number = 0
}
