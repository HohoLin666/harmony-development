import { AppBar } from '../components/common/AppBar'
import { QuestionRenderer } from '../components/question/QuestionRenderer'
import { PrimaryButton } from '../components/common/PrimaryButton'
import { FillViewModel } from '../viewmodel/FillViewModel'
import { Question } from '../model/Question'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { MockDataGenerator } from '../common/utils/MockData'
import { NavigationUtil } from '../common/utils/NavigationUtil'

/**
 * 填写问卷页
 * Stage 3: 完整填写流程 — 进度条 + 题型渲染 + 验证 + 提交
 */
@Entry
@Component
struct QuestionnaireFill {
  @State vm: FillViewModel = new FillViewModel()
  @State loading: boolean = true
  @State questionnaireId: string = ''
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = NavigationUtil.getParams()
    if (params && params['questionnaireId']) {
      this.questionnaireId = params['questionnaireId'] as string
    }
    this.loadData()
  }

  loadData(): void {
    const mockId = this.questionnaireId || MockDataGenerator.mockIds[1]
    this.questionnaireId = mockId
    this.vm.loadQuestionnaire(mockId)
    this.loading = false
  }

  build() {
    Stack() {
      if (this.loading) {
        Column() {
          AppBar({ title: '填写问卷', showBack: true, onBack: () => NavigationUtil.back() })
          Column() {
            LoadingProgress().width(36).height(36).color(AppColors.PRIMARY)
            Text('正在加载问卷...')
              .fontSize(AppDimens.FONT_BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
              .margin({ top: AppDimens.SPACE_MD })
          }
          .layoutWeight(1).width('100%')
          .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        .width('100%').height('100%')
      } else {
        Column() {
          AppBar({
            title: this.vm.questionnaire.title || '填写问卷',
            showBack: true,
            onBack: () => NavigationUtil.back()
          })

          if (this.vm.submitted) {
            this.buildSuccessPage()
          } else {
            Column() {
              this.buildProgressBar()
              Scroll(this.scroller) {
                Column() {
                  ForEach(this.vm.questions, (question: Question, index: number) => {
                    QuestionRenderer({
                      question: $question,
                      index: index + 1,
                      answerValue: this.vm.getAnswer(question.id),
                      onAnswerChange: (value: string) => {
                        this.vm.setAnswer(question.id, value)
                      }
                    })
                  })

                  PrimaryButton({
                    text: '提交问卷',
                    onButtonClick: () => { this.handleSubmit() }
                  })
                  .margin({ top: AppDimens.SPACE_LG, bottom: AppDimens.SPACE_XXL })
                }
                .padding({
                  left: AppDimens.PAGE_PADDING_H,
                  right: AppDimens.PAGE_PADDING_H,
                  top: AppDimens.PAGE_PADDING_V
                })
              }
              .layoutWeight(1).width('100%')
              .backgroundColor(AppColors.BG_SECONDARY)
              .scrollBar(BarState.Off)
            }
            .layoutWeight(1).width('100%')
          }
        }
        .width('100%').height('100%')
        .backgroundColor(AppColors.BG_SECONDARY)
      }
    }
    .width('100%').height('100%')
  }

  @Builder
  buildProgressBar() {
    Column() {
      Row() {
        Text(`完成进度：${this.vm.getCompletedCount()}/${this.vm.questions.length}`)
          .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_SECONDARY)
        Blank()
        Text(`${this.vm.getProgress()}%`)
          .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.PRIMARY).fontWeight(FontWeight.Medium)
      }
      .width('100%').margin({ bottom: AppDimens.SPACE_SM })

      Progress({ value: this.vm.getProgress(), total: 100, type: ProgressType.Linear })
        .width('100%').height(6)
        .color(AppColors.PRIMARY).backgroundColor(AppColors.DIVIDER_LIGHT)
    }
    .width('100%')
    .padding({
      left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H,
      top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_SM
    })
    .backgroundColor(AppColors.BG_PRIMARY)
  }

  @Builder
  buildSuccessPage() {
    Column() {
      Text('✅').fontSize(64).margin({ bottom: AppDimens.SPACE_LG })
      Text('提交成功').fontSize(AppDimens.FONT_H1).fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY).margin({ bottom: AppDimens.SPACE_SM })
      Text('感谢你的参与！').fontSize(AppDimens.FONT_BODY)
        .fontColor(AppColors.TEXT_SECONDARY).margin({ bottom: AppDimens.SPACE_XXL })
      PrimaryButton({ text: '返回首页', onButtonClick: () => { router.back() } }).width('60%')
    }
    .width('100%').layoutWeight(1)
    .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
    .backgroundColor(AppColors.BG_SECONDARY)
  }

  handleSubmit(): void {
    const validation = this.vm.validate()
    if (!validation.valid) {
      NavigationUtil.showToast(validation.message)
      return
    }
    NavigationUtil.showDialog('确认提交', '提交后将无法修改，确认提交吗？', () => {
      this.vm.submit()
    })
  }
}
