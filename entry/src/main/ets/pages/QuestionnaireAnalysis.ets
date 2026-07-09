import { AppBar } from '../components/common/AppBar'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'

/**
 * 数据分析页（占位 — Stage 4 实现）
 */
@Entry
@Component
struct QuestionnaireAnalysis {
  build() {
    Column() {
      AppBar({ title: '数据分析', showBack: true })

      Column() {
        Text('数据分析功能即将上线')
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
