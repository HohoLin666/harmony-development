import { AppBar } from '../components/common/AppBar'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'

/**
 * 创建问卷页（占位 — Stage 2 实现）
 */
@Entry
@Component
struct QuestionnaireCreate {
  build() {
    Column() {
      AppBar({ title: '创建问卷', showBack: true })

      Column() {
        Text('创建问卷功能即将上线')
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
