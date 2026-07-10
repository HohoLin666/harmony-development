import { AppBar } from '../components/common/AppBar'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { AuthService, AuthResult } from '../services/AuthService'
import { User } from '../model/User'

/**
 * 个人信息编辑页 — 修改头像/用户名/昵称/密码
 */
@Entry
@Component
struct ProfileEdit {
  @State username: string = ''
  @State nickname: string = ''
  @State avatar: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State errorMsg: string = ''
  @State avatarText: string = ''

  aboutToAppear(): void {
    const user: User | null = AuthService.getCurrentUser()
    if (user) {
      this.username = user.username
      this.nickname = user.nickname
      this.avatar = user.avatar
      this.avatarText = user.nickname.charAt(0).toUpperCase()
    }
  }

  build() {
    Column() {
      AppBar({ title: '个人信息', showBack: true, onBack: () => NavigationUtil.back() })

      Scroll() {
        Column() {
          // 头像区
          Column() {
            Stack() {
              if (this.avatar && this.avatar.length > 0) {
                Image(this.avatar).width(80).height(80).borderRadius(40)
              } else {
                Text(this.avatarText)
                  .fontSize(32).fontWeight(FontWeight.Bold).fontColor(AppColors.TEXT_WHITE)
              }
            }
            .width(80).height(80).borderRadius(40)
            .backgroundColor(AppColors.PRIMARY)
            .border({ width: 3, color: AppColors.TEXT_WHITE })
            .onClick(() => {
              // 头像选择 — 用 emoji 代替图片选择器
              this.showAvatarPicker = true
            })

            Text('点击更换头像')
              .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
              .margin({ top: AppDimens.SPACE_SM })
          }
          .width('100%').alignItems(HorizontalAlign.Center)
          .margin({ top: AppDimens.SPACE_XL, bottom: AppDimens.SPACE_XL })

          // 表单区
          Column() {
            // 用户名
            this.buildFormItem('用户名', this.username, '请输入用户名', (v: string) => {
              this.username = v
              this.errorMsg = ''
            })

            // 昵称
            this.buildFormItem('昵称', this.nickname, '请输入昵称', (v: string) => {
              this.nickname = v
              this.errorMsg = ''
            })

            // 分割线
            Divider().color(AppColors.DIVIDER).margin({ top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_MD })

            Text('修改密码（留空则不修改）')
              .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
              .width('100%').margin({ bottom: AppDimens.SPACE_SM })

            // 新密码
            this.buildPasswordItem('新密码', this.newPassword, '请输入新密码', (v: string) => {
              this.newPassword = v
              this.errorMsg = ''
            })

            // 确认密码
            this.buildPasswordItem('确认密码', this.confirmPassword, '请再次输入新密码', (v: string) => {
              this.confirmPassword = v
              this.errorMsg = ''
            })

            // 错误提示
            if (this.errorMsg) {
              Text(this.errorMsg)
                .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.DANGER)
                .margin({ top: AppDimens.SPACE_SM })
            }

            // 保存按钮
            Button('保 存')
              .fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_WHITE).width('100%').height(AppDimens.BUTTON_HEIGHT)
              .backgroundColor(AppColors.PRIMARY).borderRadius(AppDimens.RADIUS_PILL)
              .margin({ top: AppDimens.SPACE_XL })
              .onClick(() => { this.handleSave() })
          }
          .width('100%')
          .padding(AppDimens.CARD_PADDING)
          .backgroundColor(AppColors.BG_PRIMARY)
          .borderRadius(AppDimens.RADIUS_LG)
        }
        .padding({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H, bottom: AppDimens.SPACE_XXL })
      }
      .layoutWeight(1).width('100%').scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor(AppColors.BG_SECONDARY)
  }

  @State showAvatarPicker: boolean = false

  @Builder
  buildFormItem(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Row() {
      Text(label).fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_SECONDARY).width(72)
      TextInput({ placeholder: placeholder, text: value })
        .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
        .backgroundColor(Color.Transparent).borderRadius(0)
        .layoutWeight(1).height(44)
        .onChange((v: string) => { onChange(v) })
    }
    .width('100%')
    .border({ width: { bottom: 1 }, color: AppColors.DIVIDER_LIGHT })
  }

  @Builder
  buildPasswordItem(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Row() {
      Text(label).fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_SECONDARY).width(72)
      TextInput({ placeholder: placeholder, text: value })
        .type(InputType.Password)
        .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
        .backgroundColor(Color.Transparent).borderRadius(0)
        .layoutWeight(1).height(44)
        .onChange((v: string) => { onChange(v) })
    }
    .width('100%')
    .border({ width: { bottom: 1 }, color: AppColors.DIVIDER_LIGHT })
    .margin({ bottom: AppDimens.SPACE_SM })
  }

  handleSave(): void {
    // 1. 修改用户名
    const usernameResult: AuthResult = AuthService.updateUsername(this.username.trim())
    if (!usernameResult.success && usernameResult.message !== '用户名未变化') {
      this.errorMsg = usernameResult.message
      return
    }

    // 2. 验证密码
    if (this.newPassword) {
      if (this.newPassword.length < 6) {
        this.errorMsg = '新密码至少6个字符'
        return
      }
      if (this.newPassword !== this.confirmPassword) {
        this.errorMsg = '两次输入的密码不一致'
        return
      }
    }

    // 3. 修改昵称/头像/密码
    const result: AuthResult = AuthService.updateProfile(
      this.nickname.trim(),
      this.avatar,
      this.newPassword
    )
    if (result.success) {
      NavigationUtil.showToast('保存成功')
      NavigationUtil.back()
    } else {
      this.errorMsg = result.message
    }
  }
}
