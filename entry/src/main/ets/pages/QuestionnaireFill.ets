import { AppBar } from '../components/common/AppBar'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'

/**
 * 填写问卷页（占位 — Stage 3 实现）
 */
@Entry
@Component
struct QuestionnaireFill {
  build() {
    Column() {
      AppBar({ title: '填写问卷', showBack: true })

      Column() {
        Text('填写问卷功能即将上线')
          .fontSize(AppDimens.FONT_H3)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
