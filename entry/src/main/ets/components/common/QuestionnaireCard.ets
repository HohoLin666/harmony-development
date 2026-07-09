import { Questionnaire } from '../../model/Questionnaire'
import { PublishStatus, PublishStatusLabel, PublishStatusColor } from '../../model/enums/PublishStatus'
import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 问卷卡片组件 — 用于列表展示
 * @param questionnaire 问卷数据
 * @param onClick 点击回调
 */
@Component
export struct QuestionnaireCard {
  @ObjectLink questionnaire: Questionnaire
  onClick?: () => void

  build() {
    Column() {
      // 标题行
      Row() {
        Text(this.questionnaire.title)
          .fontSize(AppDimens.FONT_H3)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 状态标签
        Text(PublishStatusLabel[this.questionnaire.status])
          .fontSize(AppDimens.FONT_CAPTION)
          .fontColor(PublishStatusColor[this.questionnaire.status])
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(AppDimens.RADIUS_PILL)
          .border({ width: 1, color: PublishStatusColor[this.questionnaire.status] })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: AppDimens.SPACE_SM })

      // 描述
      if (this.questionnaire.description) {
        Text(this.questionnaire.description)
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: AppDimens.SPACE_SM })
      }

      // 底部信息行
      Row() {
        Row() {
          Text(`${this.questionnaire.responseCount} 份回答`)
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)

          // 分隔符
          Text('|')
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.DIVIDER)
            .margin({ left: AppDimens.SPACE_SM, right: AppDimens.SPACE_SM })

          Text(`${this.questionnaire.questionCount} 题`)
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)
        }

        if (this.questionnaire.status === PublishStatus.PUBLISHED && this.questionnaire.isExpired()) {
          Text('已截止')
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.DANGER)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
    .onClick(() => {
      if (this.onClick) {
        this.onClick()
      }
    })
  }
}
