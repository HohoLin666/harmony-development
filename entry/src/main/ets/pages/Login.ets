import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { AuthService, AuthResult } from '../services/AuthService'

/**
 * 登录页 — 账号密码登录
 */
@Entry
@Component
struct Login {
  @State username: string = ''
  @State password: string = ''
  @State loading: boolean = false
  @State errorMsg: string = ''

  aboutToAppear(): void {
    AuthService.init()
  }

  build() {
    Column() {
      // 顶部品牌区
      Column() {
        Text('📋')
          .fontSize(48)
          .margin({ bottom: AppDimens.SPACE_MD })
        Text('问卷星球')
          .fontSize(AppDimens.FONT_H1)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
        Text('轻松创建，快速收集')
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.TEXT_TERTIARY)
          .margin({ top: AppDimens.SPACE_SM })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 80, bottom: AppDimens.SPACE_XXL })

      // 表单区
      Column() {
        // 用户名
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .fontSize(AppDimens.FONT_BODY)
          .height(50)
          .backgroundColor(AppColors.BG_GREY)
          .borderRadius(AppDimens.RADIUS_MD)
          .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
          .margin({ bottom: AppDimens.SPACE_MD })
          .onChange((value: string) => {
            this.username = value
            this.errorMsg = ''
          })

        // 密码
        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .fontSize(AppDimens.FONT_BODY)
          .height(50)
          .backgroundColor(AppColors.BG_GREY)
          .borderRadius(AppDimens.RADIUS_MD)
          .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
          .margin({ bottom: AppDimens.SPACE_SM })
          .onChange((value: string) => {
            this.password = value
            this.errorMsg = ''
          })

        // 错误提示
        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.DANGER)
            .margin({ top: AppDimens.SPACE_SM, bottom: AppDimens.SPACE_SM })
        }

        // 登录按钮
        Button(this.loading ? '登录中...' : '登 录')
          .fontSize(AppDimens.FONT_H3)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_WHITE)
          .width('100%')
          .height(AppDimens.BUTTON_HEIGHT)
          .backgroundColor(this.loading ? AppColors.TEXT_TERTIARY : AppColors.PRIMARY)
          .borderRadius(AppDimens.RADIUS_PILL)
          .enabled(!this.loading)
          .margin({ top: AppDimens.SPACE_XL })
          .onClick(() => {
            this.handleLogin()
          })

        // 注册入口
        Row() {
          Text('还没有账号？')
            .fontSize(AppDimens.FONT_BODY)
            .fontColor(AppColors.TEXT_TERTIARY)
          Text('立即注册')
            .fontSize(AppDimens.FONT_BODY)
            .fontColor(AppColors.PRIMARY)
            .fontWeight(FontWeight.Medium)
            .margin({ left: AppDimens.SPACE_SM })
            .onClick(() => {
              NavigationUtil.pushUrl('pages/Register')
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: AppDimens.SPACE_XXL })
      }
      .width('100%')
      .padding({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BG_PRIMARY)
  }

  handleLogin(): void {
    if (this.loading) return
    if (!this.username.trim()) {
      this.errorMsg = '请输入用户名'
      return
    }
    if (!this.password) {
      this.errorMsg = '请输入密码'
      return
    }
    this.loading = true
    const result: AuthResult = AuthService.login(this.username.trim(), this.password)
    this.loading = false
    if (result.success) {
      NavigationUtil.replaceUrl('pages/Index')
    } else {
      this.errorMsg = result.message
    }
  }

  onBackPress(): boolean {
    return true // 阻止返回，未登录不能退出
  }
}
