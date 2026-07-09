import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 空状态组件 — 居中插画 + 提示文案 + 操作按钮
 * @param text 提示文案
 * @param actionText 操作按钮文案（可选，不传则不显示按钮）
 * @param onAction 按钮点击回调
 */
@Component
export struct EmptyState {
  @Prop text: string = '暂无数据'
  @Prop actionText: string = ''
  onAction?: () => void

  build() {
    Column() {
      // 空状态图标
      Text('📋')
        .fontSize(64)

      Text(this.text)
        .fontSize(AppDimens.FONT_BODY)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ top: AppDimens.SPACE_LG, bottom: AppDimens.SPACE_LG })
        .textAlign(TextAlign.Center)

      if (this.actionText) {
        Button(this.actionText)
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.TEXT_WHITE)
          .backgroundColor(AppColors.PRIMARY)
          .borderRadius(AppDimens.RADIUS_PILL)
          .height(AppDimens.BUTTON_HEIGHT)
          .padding({ left: 24, right: 24 })
          .onClick(() => {
            if (this.onAction) {
              this.onAction()
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
