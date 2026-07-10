import { QuestionType } from '../../model/enums/QuestionType'
import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 题型选择器 — 网格展示所有可用题型
 * 参照选题文档卡片式选择风格
 */

interface TypeOption {
  type: QuestionType
  label: string
  icon: string
  description: string
}

const TYPE_OPTIONS: TypeOption[] = [
  { type: QuestionType.SINGLE, label: '单选', icon: '☉', description: '选择一个选项' },
  { type: QuestionType.MULTI, label: '多选', icon: '☑', description: '选择多个选项' },
  { type: QuestionType.TEXT, label: '填空', icon: '✎', description: '输入文本回答' },
  { type: QuestionType.TEXTAREA, label: '文本', icon: '📄', description: '多行文本输入' },
  { type: QuestionType.RATE, label: '评分', icon: '⭐', description: '1-10分打分' },
  { type: QuestionType.DATE, label: '日期', icon: '📅', description: '选择日期' },
  { type: QuestionType.NUMBER, label: '数字', icon: '#', description: '输入数字' },
  { type: QuestionType.MATRIX, label: '矩阵', icon: '⊞', description: '矩阵选择' }
]

@Component
export struct QuestionTypePicker {
  @Prop visible: boolean = false
  onSelect?: (type: QuestionType) => void
  onClose?: () => void

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 不可见时返回空容器
      if (!this.visible) {
        Column() {
        }
        .width('100%').height('100%')
      } else {
        // 遮罩层
        Column()
          .width('100%').height('100%')
          .backgroundColor('rgba(0,0,0,0.3)')
          .onClick(() => { if (this.onClose) this.onClose() })

        // 底部弹出面板
        Column() {
          // 标题栏
          Row() {
            Text('选择题型')
              .fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)
            Blank()
            Text('取消')
              .fontSize(AppDimens.FONT_BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
              .onClick(() => { if (this.onClose) this.onClose() })
          }
          .width('100%').padding(AppDimens.CARD_PADDING)
          .margin({ bottom: AppDimens.SPACE_SM })

          // 题型网格
          Grid() {
            ForEach(TYPE_OPTIONS, (option: TypeOption) => {
              GridItem() {
                Column() {
                  Text(option.icon).fontSize(28)
                    .margin({ bottom: AppDimens.SPACE_SM })
                  Text(option.label).fontSize(AppDimens.FONT_BODY)
                    .fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY)
                  Text(option.description).fontSize(AppDimens.FONT_CAPTION)
                    .fontColor(AppColors.TEXT_TERTIARY).margin({ top: 2 })
                }
                .width('100%')
                .padding({ top: AppDimens.SPACE_LG, bottom: AppDimens.SPACE_LG })
                .borderRadius(AppDimens.RADIUS_MD)
                .backgroundColor(AppColors.BG_PRIMARY)
                .border({ width: 1, color: AppColors.DIVIDER_LIGHT })
                .onClick(() => {
                  if (this.onSelect) this.onSelect(option.type)
                })
              }
            }, (option: TypeOption) => option.type)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(AppDimens.SPACE_SM)
          .rowsGap(AppDimens.SPACE_SM)
          .padding({
            left: AppDimens.CARD_PADDING,
            right: AppDimens.CARD_PADDING,
            bottom: AppDimens.SPACE_XXL
          })
          .height(360)
        }
        .width('100%')
        .backgroundColor(AppColors.BG_SECONDARY)
        .borderRadius({ topLeft: AppDimens.RADIUS_LG, topRight: AppDimens.RADIUS_LG })
        .animation({ duration: 200, curve: Curve.EaseOut })
      }
    }
    .width('100%').height('100%')
  }
}
