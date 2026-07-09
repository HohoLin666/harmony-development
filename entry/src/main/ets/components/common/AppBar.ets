import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 顶部导航栏 — 蓝底白字，参照选题文档风格
 * @param title 标题文本
 * @param showBack 是否显示返回按钮
 * @param onBack 返回点击回调
 */
@Component
export struct AppBar {
  @Prop title: string = '问卷大厅'
  @Prop showBack: boolean = false
  onBack?: () => void

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
        // 占位保持居中
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

      Blank().width(40)
    }
    .width('100%')
    .height(AppDimens.APP_BAR_HEIGHT)
    .backgroundColor(AppColors.PRIMARY)
    .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}
