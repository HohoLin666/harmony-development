import { Question, Option } from '../../model/Question'
import { QuestionType } from '../../model/enums/QuestionType'
import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 题目渲染器 — 根据题型分派对应的填写组件
 * @param question 题目数据
 * @param index 题号
 * @param answerValue 当前答案
 * @param onAnswerChange 答案变更回调
 */
@Component
export struct QuestionRenderer {
  @Prop question: Question
  @Prop answerValue: string = ''
  @Prop index: number = 1
  onAnswerChange?: (value: string) => void

  build() {
    Column() {
      // 题目标题区
      Row() {
        Text(`${this.index}.`)
          .fontSize(AppDimens.FONT_H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY)
          .margin({ right: AppDimens.SPACE_SM })

        Text(this.question.title || '未命名题目')
          .fontSize(AppDimens.FONT_H3)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        if (this.question.required) {
          Text('*')
            .fontSize(AppDimens.FONT_H3)
            .fontColor(AppColors.DANGER)
        }
      }
      .width('100%')
      .margin({ bottom: AppDimens.SPACE_LG })

      // 根据题型分发
      if (this.question.type === QuestionType.SINGLE) {
        SingleChoice({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      } else if (this.question.type === QuestionType.MULTI) {
        MultiChoice({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      } else if (this.question.type === QuestionType.TEXT) {
        TextFill({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      } else if (this.question.type === QuestionType.TEXTAREA) {
        TextAreaFill({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      } else if (this.question.type === QuestionType.RATE) {
        RateScore({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      } else if (this.question.type === QuestionType.NUMBER) {
        NumberFill({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      } else if (this.question.type === QuestionType.DATE) {
        DateFill({
          question: this.question,
          answerValue: this.answerValue,
          onAnswerChange: this.onAnswerChange
        })
      }
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }
}

// ========== 各题型填写组件 ==========

/**
 * 单选题 — 列表选一
 */
@Component
struct SingleChoice {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  build() {
    Column() {
      ForEach(this.question.options, (option: Option, index: number) => {
        Row() {
          Text(this.answerValue === option.id ? '●' : '○')
            .fontSize(20)
            .fontColor(this.answerValue === option.id ? AppColors.PRIMARY : AppColors.TEXT_TERTIARY)
            .margin({ right: AppDimens.SPACE_MD })
            .width(24)

          Text(option.text || `选项 ${index + 1}`)
            .fontSize(AppDimens.FONT_BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .layoutWeight(1)

          if (option.isCustom) {
            Text('(自定义)')
              .fontSize(AppDimens.FONT_CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
        }
        .width('100%')
        .padding({ top: 10, bottom: 10, left: AppDimens.SPACE_SM, right: AppDimens.SPACE_SM })
        .borderRadius(AppDimens.RADIUS_MD)
        .backgroundColor(this.answerValue === option.id ? AppColors.PRIMARY_LIGHT : Color.Transparent)
        .margin({ bottom: AppDimens.SPACE_SM })
        .onClick(() => {
          if (this.onAnswerChange) this.onAnswerChange(option.id)
        })
      })
    }
  }
}

/**
 * 多选题 — 列表选多个
 */
@Component
struct MultiChoice {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  private getSelectedIds(): string[] {
    if (!this.answerValue) return []
    try {
      const arr: string[] = JSON.parse(this.answerValue)
      return arr
    } catch (e) {
      return []
    }
  }

  private toggleOption(optionId: string): void {
    const selected = this.getSelectedIds()
    const idx = selected.indexOf(optionId)
    if (idx >= 0) {
      selected.splice(idx, 1)
    } else {
      selected.push(optionId)
    }
    if (this.onAnswerChange) this.onAnswerChange(JSON.stringify(selected))
  }

  private isSelected(optionId: string): boolean {
    return this.getSelectedIds().includes(optionId)
  }

  build() {
    Column() {
      Text('（可多选）')
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ bottom: AppDimens.SPACE_SM })

      ForEach(this.question.options, (option: Option, index: number) => {
        Row() {
          Text(this.isSelected(option.id) ? '☑' : '☐')
            .fontSize(20)
            .fontColor(this.isSelected(option.id) ? AppColors.PRIMARY : AppColors.TEXT_TERTIARY)
            .margin({ right: AppDimens.SPACE_MD })
            .width(24)

          Text(option.text || `选项 ${index + 1}`)
            .fontSize(AppDimens.FONT_BODY)
            .fontColor(AppColors.TEXT_PRIMARY)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: 10, bottom: 10, left: AppDimens.SPACE_SM, right: AppDimens.SPACE_SM })
        .borderRadius(AppDimens.RADIUS_MD)
        .backgroundColor(this.isSelected(option.id) ? AppColors.PRIMARY_LIGHT : Color.Transparent)
        .margin({ bottom: AppDimens.SPACE_SM })
        .onClick(() => {
          this.toggleOption(option.id)
        })
      })
    }
  }
}

/**
 * 填空题 — 单行文本
 */
@Component
struct TextFill {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  build() {
    TextInput({ placeholder: '请输入回答', text: this.answerValue })
      .fontSize(AppDimens.FONT_BODY)
      .borderRadius(AppDimens.RADIUS_SM)
      .backgroundColor(AppColors.BG_GREY)
      .padding(AppDimens.SPACE_MD)
      .onChange((value: string) => {
        if (this.onAnswerChange) this.onAnswerChange(value)
      })
  }
}

/**
 * 文本题 — 多行文本
 */
@Component
struct TextAreaFill {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  build() {
    TextArea({ placeholder: '请输入回答', text: this.answerValue })
      .fontSize(AppDimens.FONT_BODY)
      .borderRadius(AppDimens.RADIUS_SM)
      .backgroundColor(AppColors.BG_GREY)
      .padding(AppDimens.SPACE_MD)
      .height(120)
      .onChange((value: string) => {
        if (this.onAnswerChange) this.onAnswerChange(value)
      })
  }
}

/**
 * 评分题 — 星级/数字评分
 */
@Component
struct RateScore {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  private get maxRate(): number {
    return this.question.maxRate || 5
  }

  private get currentRate(): number {
    return parseInt(this.answerValue) || 0
  }

  private get scores(): number[] {
    const result: number[] = []
    for (let i = 1; i <= this.maxRate; i++) {
      result.push(i)
    }
    return result
  }

  build() {
    Row() {
      ForEach(this.scores, (score: number) => {
        Text(score <= this.currentRate ? '★' : '☆')
          .fontSize(32)
          .fontColor(score <= this.currentRate ? AppColors.WARNING : AppColors.TEXT_PLACEHOLDER)
          .margin({ right: AppDimens.SPACE_SM })
          .onClick(() => {
            if (this.onAnswerChange) this.onAnswerChange(String(score))
          })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_MD })
  }
}

/**
 * 数字题 — 数字输入
 */
@Component
struct NumberFill {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  build() {
    TextInput({ placeholder: '请输入数字', text: this.answerValue })
      .type(InputType.Number)
      .fontSize(AppDimens.FONT_BODY)
      .borderRadius(AppDimens.RADIUS_SM)
      .backgroundColor(AppColors.BG_GREY)
      .padding(AppDimens.SPACE_MD)
      .onChange((value: string) => {
        if (this.onAnswerChange) this.onAnswerChange(value)
      })
  }
}

/**
 * 日期题 — 日期选择
 */
@Component
struct DateFill {
  @Prop question: Question
  @Prop answerValue: string = ''
  onAnswerChange?: (value: string) => void

  build() {
    DatePicker({
      start: new Date('2020-1-1'),
      end: new Date('2030-12-31'),
      selected: this.answerValue ? new Date(this.answerValue) : new Date()
    })
      .onChange((value: DatePickerResult) => {
        const dateStr = `${value.year}-${value.month}-${value.day}`
        if (this.onAnswerChange) this.onAnswerChange(dateStr)
      })
  }
}
