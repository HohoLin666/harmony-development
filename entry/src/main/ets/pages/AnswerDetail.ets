import { AppBar } from '../components/common/AppBar'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { ResponseStore, ParticipationRecord } from '../services/ResponseStore'
import { QuestionnaireStore } from '../services/QuestionnaireStore'
import { Question } from '../model/Question'
import { QuestionType, QuestionTypeLabel } from '../model/enums/QuestionType'

/**
 * 答题详情页 — 展示题目内容 + 用户选择的选项
 */
@Entry
@Component
struct AnswerDetail {
  @State questionnaireTitle: string = ''
  @State questions: Question[] = []
  @State answers: Record<string, string> = {}
  @State submittedAt: number = 0
  @State loaded: boolean = false

  aboutToAppear(): void {
    const params: Record<string, Object> = NavigationUtil.getParams()
    const recordId: string = params['recordId'] as string

    // 从 ResponseStore 找到对应提交记录
    const allRecords: ParticipationRecord[] = ResponseStore.getAll()
    for (let i: number = 0; i < allRecords.length; i++) {
      if (allRecords[i].questionnaireId === recordId && allRecords[i].submittedAt === this.parseTime(params['submittedAt'])) {
        this.questionnaireTitle = allRecords[i].questionnaireTitle
        this.answers = allRecords[i].answers
        this.submittedAt = allRecords[i].submittedAt
        this.questions = QuestionnaireStore.getQuestions(allRecords[i].questionnaireId)
        this.loaded = true
        return
      }
    }
    // 兜底：用 questionnaireId 找最新记录
    const records: ParticipationRecord[] = ResponseStore.getByQuestionnaire(recordId)
    if (records.length > 0) {
      const latest: ParticipationRecord = records[0]
      this.questionnaireTitle = latest.questionnaireTitle
      this.answers = latest.answers
      this.submittedAt = latest.submittedAt
      this.questions = QuestionnaireStore.getQuestions(latest.questionnaireId)
    }
    this.loaded = true
  }

  parseTime(val: Object): number {
    if (!val) return 0
    return parseInt(val as string) || 0
  }

  build() {
    Column() {
      AppBar({ title: '答题详情', showBack: true, onBack: () => NavigationUtil.back() })

      if (!this.loaded) {
        Column() {
          LoadingProgress().width(36).height(36).color(AppColors.PRIMARY)
        }
        .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 问卷标题
            Text(this.questionnaireTitle || '未命名问卷')
              .fontSize(AppDimens.FONT_H2).fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY).width('100%')
              .margin({ bottom: AppDimens.SPACE_SM })

            Text(`提交时间：${this.formatTime(this.submittedAt)}`)
              .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
              .width('100%').margin({ bottom: AppDimens.SPACE_LG })

            // 题目列表
            ForEach(this.questions, (question: Question, index: number) => {
              this.buildQuestionItem(question, index)
            })
          }
          .padding({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H, bottom: AppDimens.SPACE_XXL })
        }
        .layoutWeight(1).width('100%').scrollBar(BarState.Off)
      }
    }
    .width('100%').height('100%').backgroundColor(AppColors.BG_SECONDARY)
  }

  @Builder
  buildQuestionItem(question: Question, index: number) {
    Column() {
      // 题号 + 题型标签
      Row() {
        Text(`${index + 1}.`)
          .fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Bold)
          .fontColor(AppColors.PRIMARY).margin({ right: AppDimens.SPACE_SM })
        Text(question.title || '未命名题目')
          .fontSize(AppDimens.FONT_H3).fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
        Text(QuestionTypeLabel.get(question.type) || '')
          .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
          .backgroundColor(AppColors.BG_GREY)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(8)
      }
      .width('100%').margin({ bottom: AppDimens.SPACE_MD })

      // 用户答案
      this.buildAnswer(question)
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  @Builder
  buildAnswer(question: Question) {
    Column() {
      Text('你的回答：')
        .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
        .margin({ bottom: AppDimens.SPACE_SM })

      if (question.type === QuestionType.SINGLE) {
        // 单选：显示选中的选项文本
        Text(this.getOptionText(question, this.answers[question.id]))
          .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
          .padding({ left: AppDimens.SPACE_MD, top: 8, bottom: 8, right: AppDimens.SPACE_MD })
          .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_SM)

      } else if (question.type === QuestionType.MULTI) {
        // 多选：显示所有选中的选项
        this.buildMultiAnswer(question)

      } else if (question.type === QuestionType.RATE) {
        // 评分：显示分数
        Row() {
          Text(this.answers[question.id] || '未评分')
            .fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Bold)
            .fontColor(AppColors.WARNING)
          Text(` / ${question.maxRate || 5} 分`)
            .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY)
        }

      } else {
        // 填空/文本：显示原文
        Text(this.answers[question.id] || '未填写')
          .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
          .width('100%')
          .padding(AppDimens.SPACE_MD)
          .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_SM)
      }
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildMultiAnswer(question: Question) {
    Column() {
      const answer: string = this.answers[question.id]
      if (answer && answer.length > 0) {
        try {
          const arr: string[] = JSON.parse(answer)
          ForEach(arr, (optionId: string) => {
            Text('✓ ' + this.getOptionText(question, optionId))
              .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
              .padding({ left: AppDimens.SPACE_MD, top: 4, bottom: 4, right: AppDimens.SPACE_MD })
              .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_SM)
              .margin({ bottom: 4 })
          })
        } catch (e) {
          Text('未选择')
            .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY)
        }
      } else {
        Text('未选择')
          .fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY)
      }
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  /** 根据 optionId 获取选项文本 */
  getOptionText(question: Question, optionId: string): string {
    if (!optionId) return '未选择'
    for (let i: number = 0; i < question.options.length; i++) {
      if (question.options[i].id === optionId) {
        return question.options[i].text || `选项${i + 1}`
      }
    }
    return '未选择'
  }

  formatTime(timestamp: number): string {
    if (!timestamp) return '未知'
    const date: Date = new Date(timestamp)
    return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()} ${date.getHours()}:${String(date.getMinutes()).padStart(2, '0')}`
  }
}
