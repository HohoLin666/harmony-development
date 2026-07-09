import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 顶部导航栏 — 蓝底白字，参照选题文档风格
 * @param title 标题文本
 * @param showBack 是否显示返回按钮
 * @param actionText 右侧操作按钮文案（不传则不显示）
 * @param onBack 返回点击回调
 * @param onAction 右侧按钮点击回调
 */
@Component
export struct AppBar {
  @Prop title: string = '问卷大厅'
  @Prop showBack: boolean = false
  @Prop actionText: string = ''
  onBack?: () => void
  onAction?: () => void

  build() {
    Row() {
      if (this.showBack) {
        Text('←')
          .fontSize(20)
          .fontColor(AppColors.TEXT_WHITE)
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.onBack) {
              this.onBack()
            }
          })
      } else {
        Blank().width(40)
      }

      Text(this.title)
        .fontSize(AppDimens.FONT_H2)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_WHITE)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.actionText) {
        Text(this.actionText)
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.TEXT_WHITE)
          .padding({ left: 8, right: 4, top: 4, bottom: 4 })
          .onClick(() => {
            if (this.onAction) this.onAction()
          })
      } else {
        Blank().width(40)
      }
    }
    .width('100%')
    .height(AppDimens.APP_BAR_HEIGHT)
    .backgroundColor(AppColors.PRIMARY)
    .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}
