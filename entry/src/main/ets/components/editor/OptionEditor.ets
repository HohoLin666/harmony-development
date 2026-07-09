import { Option } from '../../model/Question'
import { IdGenerator } from '../../common/utils/IdGenerator'
import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 选项编辑器 — 支持增删选项
 */
@Component
export struct OptionEditor {
  @Prop questionId: string = ''
  @Prop options: Option[] = []
  onOptionsChange?: (options: Option[]) => void

  build() {
    Column() {
      ForEach(this.options, (option: Option, index: number) => {
        Row() {
          Text('≡')
            .fontSize(AppDimens.FONT_H3).fontColor(AppColors.TEXT_TERTIARY)
            .margin({ right: AppDimens.SPACE_SM })

          Text(String.fromCharCode(65 + index) + '.')
            .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY)
            .margin({ right: AppDimens.SPACE_SM }).width(24)

          TextInput({ placeholder: `选项 ${index + 1}`, text: option.text })
            .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
            .placeholderColor(AppColors.TEXT_PLACEHOLDER)
            .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_SM)
            .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
            .height(36).layoutWeight(1)
            .onChange((value: string) => {
              option.text = value
              if (this.onOptionsChange) this.onOptionsChange(this.options)
            })

          Button('×')
            .fontSize(20).fontColor(AppColors.TEXT_TERTIARY).backgroundColor(Color.Transparent)
            .width(32).height(32).margin({ left: AppDimens.SPACE_SM })
            .onClick(() => {
              const newOptions = [...this.options]
              newOptions.splice(index, 1)
              if (this.onOptionsChange) this.onOptionsChange(newOptions)
            })
        }
        .width('100%')
        .padding({ left: AppDimens.SPACE_SM, right: AppDimens.SPACE_SM, top: 6, bottom: 6 })
        .borderRadius(AppDimens.RADIUS_MD).backgroundColor(AppColors.BG_GREY)
        .margin({ bottom: AppDimens.SPACE_SM })
      })

      Row() {
        Row() {
          Text('+').fontSize(AppDimens.FONT_H3).fontColor(AppColors.PRIMARY).margin({ right: AppDimens.SPACE_SM })
          Text('添加选项').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.PRIMARY)
        }
        .padding({ top: AppDimens.SPACE_SM, bottom: AppDimens.SPACE_SM })
        .onClick(() => {
          const newOption = new Option()
          newOption.id = IdGenerator.generate()
          newOption.questionId = this.questionId
          newOption.text = ''
          newOption.orderIndex = this.options.length
          const newOptions = [...this.options, newOption]
          if (this.onOptionsChange) this.onOptionsChange(newOptions)
        })

        Blank()

        if (!this.options.some(o => o.isCustom)) {
          Text('添加"其他"').fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
            .onClick(() => {
              const otherOption = new Option()
              otherOption.id = IdGenerator.generate()
              otherOption.questionId = this.questionId
              otherOption.text = '其他'
              otherOption.isCustom = true
              otherOption.orderIndex = this.options.length
              const newOptions = [...this.options, otherOption]
              if (this.onOptionsChange) this.onOptionsChange(newOptions)
            })
        }
      }
      .width('100%').padding({ left: AppDimens.SPACE_SM, right: AppDimens.SPACE_SM })
    }
  }
}
