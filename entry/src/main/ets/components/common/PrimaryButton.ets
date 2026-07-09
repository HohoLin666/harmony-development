import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 主操作按钮 — 蓝色圆角，参考选题文档 CTA 按钮风格
 * @param text 按钮文案
 * @param disabled 是否禁用
 * @param onClick 点击回调
 */
@Component
export struct PrimaryButton {
  @Prop text: string = '确定'
  @Prop disabled: boolean = false
  onClick?: () => void

  build() {
    Button(this.text)
      .width('100%')
      .height(AppDimens.BUTTON_HEIGHT)
      .fontSize(AppDimens.FONT_H3)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.disabled ? AppColors.TEXT_WHITE : AppColors.TEXT_WHITE)
      .backgroundColor(this.disabled ? AppColors.TEXT_TERTIARY : AppColors.PRIMARY)
      .borderRadius(AppDimens.RADIUS_PILL)
      .enabled(!this.disabled)
      .opacity(this.disabled ? 0.5 : 1.0)
      .onClick(() => {
        if (!this.disabled && this.onClick) {
          this.onClick()
        }
      })
  }
}
