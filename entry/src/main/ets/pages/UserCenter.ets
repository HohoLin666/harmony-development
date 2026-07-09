import { AppBar } from '../components/common/AppBar'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'

/**
 * 用户中心页（占位 — Stage 5 实现）
 */
@Entry
@Component
struct UserCenter {
  build() {
    Column() {
      AppBar({ title: '我的' })

      Column() {
        Text('用户中心功能即将上线')
          .fontSize(AppDimens.FONT_H3)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(AppColors.BG_SECONDARY)
    }
    .width('100%')
    .height('100%')
  }
}
