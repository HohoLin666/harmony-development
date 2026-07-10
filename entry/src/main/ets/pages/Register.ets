import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { AuthService } from '../services/AuthService'

/**
 * 注册页
 */
@Entry
@Component
struct Register {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State nickname: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24).fontColor(AppColors.TEXT_PRIMARY)
          .width(44).height(44).textAlign(TextAlign.Center)
          .onClick(() => { NavigationUtil.back() })
        Text('注册账号')
          .fontSize(AppDimens.FONT_H2).fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY).margin({ left: AppDimens.SPACE_MD })
        Blank()
      }
      .width('100%')
      .padding({ left: AppDimens.SPACE_MD, top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_MD })

      // 表单区
      Column() {
        // 用户名
        TextInput({ placeholder: '请输入用户名（至少3位）', text: this.username })
          .fontSize(AppDimens.FONT_BODY).height(50)
          .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_MD)
          .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
          .margin({ bottom: AppDimens.SPACE_MD })
          .onChange((value: string) => { this.username = value; this.errorMsg = '' })

        // 昵称
        TextInput({ placeholder: '请输入昵称（选填）', text: this.nickname })
          .fontSize(AppDimens.FONT_BODY).height(50)
          .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_MD)
          .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
          .margin({ bottom: AppDimens.SPACE_MD })
          .onChange((value: string) => { this.nickname = value })

        // 密码
        TextInput({ placeholder: '请输入密码（至少6位）', text: this.password })
          .type(InputType.Password).fontSize(AppDimens.FONT_BODY).height(50)
          .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_MD)
          .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
          .margin({ bottom: AppDimens.SPACE_MD })
          .onChange((value: string) => { this.password = value; this.errorMsg = '' })

        // 确认密码
        TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
          .type(InputType.Password).fontSize(AppDimens.FONT_BODY).height(50)
          .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_MD)
          .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
          .margin({ bottom: AppDimens.SPACE_SM })
          .onChange((value: string) => { this.confirmPassword = value; this.errorMsg = '' })

        // 错误提示
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.DANGER)
            .margin({ top: AppDimens.SPACE_SM, bottom: AppDimens.SPACE_SM })
        }

        // 注册按钮
        Button(this.loading ? '注册中...' : '注 册')
          .fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_WHITE).width('100%').height(AppDimens.BUTTON_HEIGHT)
          .backgroundColor(this.loading ? AppColors.TEXT_TERTIARY : AppColors.PRIMARY)
          .borderRadius(AppDimens.RADIUS_PILL).enabled(!this.loading)
          .margin({ top: AppDimens.SPACE_XL })
          .onClick(() => { this.handleRegister() })
      }
      .width('100%')
      .padding({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H, top: AppDimens.SPACE_LG })

      Blank()
    }
    .width('100%').height('100%')
    .backgroundColor(AppColors.BG_PRIMARY)
  }

  handleRegister(): void {
    if (this.loading) return
    if (!this.username.trim() || this.username.trim().length < 3) {
      this.errorMsg = '用户名至少3个字符'
      return
    }
    if (!this.password || this.password.length < 6) {
      this.errorMsg = '密码至少6个字符'
      return
    }
    if (this.password !== this.confirmPassword) {
      this.errorMsg = '两次输入的密码不一致'
      return
    }
    this.loading = true
    AuthService.register(this.username.trim(), this.password, this.nickname.trim()).then((result) => {
      this.loading = false
      if (result.success) {
        NavigationUtil.showToast('注册成功，请登录')
        NavigationUtil.back()
      } else {
        this.errorMsg = result.message
      }
    }).catch(() => {
      this.loading = false
      this.errorMsg = '网络异常，请重试'
    })
  }
}
