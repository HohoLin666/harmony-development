import { Question, Option } from '../../model/Question'
import { QuestionType, QuestionTypeLabel } from '../../model/enums/QuestionType'
import { OptionEditor } from './OptionEditor'
import { IdGenerator } from '../../common/utils/IdGenerator'
import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 题目编辑器卡片 — 单个题目的编辑区域
 * @param question 题目数据
 * @param index 题目序号
 * @param onDelete 删除回调
 */
@Component
export struct QuestionEditor {
  @Link question: Question
  @Prop index: number = 1
  onDelete?: () => void
  onChangeType?: () => void

  build() {
    Column() {
      // 标题栏：序号 + 题型标签 + 操作按钮
      Row() {
        Text(`${this.index}.`)
          .fontSize(AppDimens.FONT_H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY)
          .margin({ right: AppDimens.SPACE_SM })

        // 题型标签
        Row() {
          Text(QuestionTypeLabel.get(this.question.type) || '未知')
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.PRIMARY)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        }
        .borderRadius(AppDimens.RADIUS_PILL)
        .backgroundColor(AppColors.PRIMARY_LIGHT)
        .onClick(() => {
          if (this.onChangeType) this.onChangeType()
        })

        Blank()

        // 删除按钮
        Text('🗑')
          .fontSize(AppDimens.FONT_H3)
          .onClick(() => {
            if (this.onDelete) this.onDelete()
          })
      }
      .width('100%')
      .padding({ bottom: AppDimens.SPACE_SM })

      // 题目文本输入
      TextInput({ placeholder: '请输入题目', text: this.question.title })
        .fontSize(AppDimens.FONT_BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
        .placeholderColor(AppColors.TEXT_PLACEHOLDER)
        .backgroundColor(AppColors.BG_GREY)
        .borderRadius(AppDimens.RADIUS_SM)
        .padding(AppDimens.SPACE_MD)
        .margin({ bottom: AppDimens.SPACE_MD })
        .onChange((value: string) => {
          this.question.title = value
        })

      // 选项编辑区（单选/多选/矩阵）
      if (this.needsOptions()) {
        OptionEditor({
          questionId: this.question.id,
          options: this.question.options,
          onOptionsChange: (newOptions: Option[]) => {
            this.question.options = newOptions
          }
        })
          .margin({ bottom: AppDimens.SPACE_SM })
      }

      // 评分题配置
      if (this.question.type === QuestionType.RATE) {
        this.buildRateConfig()
      }

      // 必填开关
      Row() {
        Text('必答题')
          .fontSize(AppDimens.FONT_CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.question.required })
          .selectedColor(AppColors.PRIMARY)
          .onChange((value: boolean) => {
            this.question.required = value
          })
      }
      .width('100%')
      .padding({ top: AppDimens.SPACE_SM })
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  /** 是否需要选项列表 */
  needsOptions(): boolean {
    return this.question.type === QuestionType.SINGLE ||
      this.question.type === QuestionType.MULTI ||
      this.question.type === QuestionType.MATRIX
  }

  @Builder
  buildRateConfig() {
    Row() {
      Text('最高分：')
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
      TextInput({ text: String(this.question.maxRate || 5) })
        .type(InputType.Number)
        .fontSize(AppDimens.FONT_CAPTION)
        .width(60)
        .height(32)
        .backgroundColor(AppColors.BG_GREY)
        .borderRadius(AppDimens.RADIUS_SM)
        .onChange((value: string) => {
          this.question.maxRate = parseInt(value) || 5
        })
    }
    .margin({ top: AppDimens.SPACE_SM, bottom: AppDimens.SPACE_SM })
  }
}
