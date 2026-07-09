import { AppBar } from '../components/common/AppBar'
import { PieChart, BarChart, StatItem } from '../components/chart/PieChart'
import { AnalysisViewModel } from '../viewmodel/AnalysisViewModel'
import { Question } from '../model/Question'
import { QuestionType, QuestionTypeLabel } from '../model/enums/QuestionType'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { MockDataGenerator } from '../common/utils/MockData'
import { router } from '@kit.ArkUI'

/**
 * 数据分析页
 * Stage 4: 总体概览 + 逐题统计 + 饼图/柱状图 + 文本答案展示
 */
@Entry
@Component
struct QuestionnaireAnalysis {
  @State vm: AnalysisViewModel = new AnalysisViewModel()
  @State loading: boolean = true
  @State selectedQuestionIndex: number = -1 // -1 = 概览

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    const qId = params?.['questionnaireId'] as string || MockDataGenerator.mockIds[0]
    this.vm.loadData(qId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() {
        AppBar({ title: '数据分析', showBack: true, onBack: () => router.back() })
        Column() {
          LoadingProgress().width(36).height(36).color(AppColors.PRIMARY)
          Text('正在加载...').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY).margin({ top: AppDimens.SPACE_MD })
        }
        .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      }
      .width('100%').height('100%')
    }

    Column() {
      AppBar({
        title: this.vm.questionnaire.title || '数据分析',
        showBack: true,
        onBack: () => router.back()
      })

      if (this.selectedQuestionIndex >= 0) {
        this.buildQuestionDetail()
      } else {
        this.buildOverview()
      }
    }
    .width('100%').height('100%')
    .backgroundColor(AppColors.BG_SECONDARY)
  }

  // ==================== 概览页 ====================

  @Builder
  buildOverview() {
    Scroll() {
      Column() {
        // 总览卡片
        this.buildSummaryCard()

        // 题目列表
        ForEach(this.vm.questions, (question: Question, index: number) => {
          this.buildQuestionCard(question, index)
        })
      }
      .padding({
        left: AppDimens.PAGE_PADDING_H,
        right: AppDimens.PAGE_PADDING_H,
        top: AppDimens.PAGE_PADDING_V,
        bottom: AppDimens.SPACE_XXL
      })
    }
    .layoutWeight(1).width('100%')
    .scrollBar(BarState.Off)
  }

  /** 总览卡片 */
  @Builder
  buildSummaryCard() {
    Column() {
      Text('问卷统计概览')
        .fontSize(AppDimens.FONT_H3)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: AppDimens.SPACE_LG })

      Row() {
        this.buildStatItem('回收', `${this.vm.getTotalResponses()}`)
        this.buildStatItem('题目', `${this.vm.questions.length}`)
        this.buildStatItem('完成率', '85%')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  @Builder
  buildStatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(AppDimens.FONT_H1)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.PRIMARY)
      Text(label)
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ top: AppDimens.SPACE_SM })
    }
    .alignItems(HorizontalAlign.Center)
  }

  /** 每题的概览卡片 */
  @Builder
  buildQuestionCard(question: Question, index: number) {
    Column() {
      Row() {
        Text(`${index + 1}. [${QuestionTypeLabel[question.type] || '未知'}]`)
          .fontSize(AppDimens.FONT_CAPTION)
          .fontColor(AppColors.PRIMARY)
          .fontWeight(FontWeight.Medium)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(AppDimens.RADIUS_PILL)
          .backgroundColor(AppColors.PRIMARY_LIGHT)

        Blank()

        Text('查看详情 →')
          .fontSize(AppDimens.FONT_CAPTION)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .width('100%')
      .margin({ bottom: AppDimens.SPACE_SM })

      Text(question.title || '未命名题目')
        .fontSize(AppDimens.FONT_BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
    .onClick(() => {
      this.selectedQuestionIndex = index
    })
  }

  // ==================== 逐题详情页 ====================

  @Builder
  buildQuestionDetail() {
    const question = this.vm.questions[this.selectedQuestionIndex]

    Scroll() {
      Column() {
        // 返回按钮 + 标题
        Row() {
          Text('← 返回概览')
            .fontSize(AppDimens.FONT_BODY)
            .fontColor(AppColors.PRIMARY)
            .onClick(() => { this.selectedQuestionIndex = -1 })
          Blank()
        }
        .width('100%')
        .padding({
          left: AppDimens.PAGE_PADDING_H,
          right: AppDimens.PAGE_PADDING_H,
          top: AppDimens.SPACE_MD,
          bottom: AppDimens.SPACE_SM
        })

        // 题目详情卡片
        Column() {
          Text(question.title)
            .fontSize(AppDimens.FONT_H2)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ bottom: AppDimens.SPACE_SM })

          Text(`共 ${this.vm.stats[question.id]?.total || 0} 人次回答`)
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)
            .margin({ bottom: AppDimens.SPACE_XL })

          // 按题型展示
          if (question.type === QuestionType.SINGLE) {
            PieChart({
              title: '选项分布',
              data: this.vm.getPieData(question),
              total: this.vm.stats[question.id]?.total || 0
            })
          } else if (question.type === QuestionType.MULTI) {
            BarChart({
              title: '选项分布（可多选）',
              data: this.vm.getBarData(question),
              maxValue: this.vm.stats[question.id]?.total || 1
            })
          } else if (question.type === QuestionType.RATE) {
            Column() {
              Text(this.vm.getScoreSummary(question))
                .fontSize(AppDimens.FONT_H3)
                .fontColor(AppColors.PRIMARY)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: AppDimens.SPACE_LG })

              BarChart({
                title: '评分分布',
                data: this.vm.getScoreDistribution(question),
                maxValue: this.vm.stats[question.id]?.total || 1
              })
            }
            .width('100%')
          } else if (question.type === QuestionType.TEXT || question.type === QuestionType.TEXTAREA) {
            this.buildTextSamples(question)
          } else if (question.type === QuestionType.NUMBER) {
            this.buildNumberStats(question)
          } else {
            Text('暂无此题型的数据展示')
              .fontSize(AppDimens.FONT_BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
        }
        .width('100%')
        .padding(AppDimens.CARD_PADDING)
        .backgroundColor(AppColors.BG_PRIMARY)
        .borderRadius(AppDimens.RADIUS_LG)
        .margin({
          left: AppDimens.PAGE_PADDING_H,
          right: AppDimens.PAGE_PADDING_H,
          bottom: AppDimens.SPACE_XXL
        })
      }
    }
    .layoutWeight(1).width('100%')
    .scrollBar(BarState.Off)
  }

  /** 文本题样本展示 */
  @Builder
  buildTextSamples(question: Question) {
    Column() {
      Text('回答样本')
        .fontSize(AppDimens.FONT_H3)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: AppDimens.SPACE_MD })

      const samples = this.vm.getTextSamples(question)
      ForEach(samples, (text: string, idx: number) => {
        Row() {
          Text(`"${text}"`)
            .fontSize(AppDimens.FONT_BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(AppDimens.SPACE_MD)
        .backgroundColor(AppColors.BG_GREY)
        .borderRadius(AppDimens.RADIUS_MD)
        .margin({ bottom: AppDimens.SPACE_SM })
      })
    }
    .width('100%')
  }

  /** 数字题统计 */
  @Builder
  buildNumberStats(question: Question) {
    const stat = this.vm.stats[question.id]
    Column() {
      Text('数字统计')
        .fontSize(AppDimens.FONT_H3)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: AppDimens.SPACE_LG })

      Row() {
        this.buildStatItem('平均', stat?.avgNumber?.toFixed(1) || '-')
        this.buildStatItem('最低', stat?.minNumber?.toString() || '-')
        this.buildStatItem('最高', stat?.maxNumber?.toString() || '-')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
  }
}
