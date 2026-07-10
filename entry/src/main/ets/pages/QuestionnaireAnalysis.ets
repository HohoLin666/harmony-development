import { AppBar } from '../components/common/AppBar'
import { PieChart, BarChart, StatItem } from '../components/chart/PieChart'
import { AnalysisViewModel } from '../viewmodel/AnalysisViewModel'
import { Question } from '../model/Question'
import { QuestionType, QuestionTypeLabel } from '../model/enums/QuestionType'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { MockDataGenerator } from '../common/utils/MockData'
import { NavigationUtil } from '../common/utils/NavigationUtil'

/**
 * 数据分析页
 * Stage 4: 总体概览 + 逐题统计 + 饼图/柱状图 + 文本答案展示
 */
@Entry
@Component
struct QuestionnaireAnalysis {
  @State vm: AnalysisViewModel = new AnalysisViewModel()
  @State loading: boolean = true
  @State selectedQuestionIndex: number = -1

  aboutToAppear(): void {
    try {
      const params: Record<string, Object> = NavigationUtil.getParams()
      const qId: string = params['questionnaireId'] as string || MockDataGenerator.mockIds[0]
      this.vm.loadData(qId)
    } catch (e) {
      // Fallback
      this.vm.loadData(MockDataGenerator.mockIds[0])
    }
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() {
        AppBar({ title: '数据分析', showBack: true, onBack: () => this.goBack() })
        Column() {
          LoadingProgress().width(36).height(36).color(AppColors.PRIMARY)
          Text('正在加载...').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY).margin({ top: AppDimens.SPACE_MD })
        }
        .layoutWeight(1).width('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      }
      .width('100%').height('100%')
    } else if (this.selectedQuestionIndex >= 0) {
      Column() {
        AppBar({
          title: this.vm.questionnaire.title || '数据分析',
          showBack: true,
          onBack: () => this.selectedQuestionIndex = -1
        })
        this.buildQuestionDetail()
      }
      .width('100%').height('100%')
      .backgroundColor(AppColors.BG_SECONDARY)
    } else {
      Column() {
        AppBar({
          title: this.vm.questionnaire.title || '数据分析',
          showBack: true,
          onBack: () => this.goBack()
        })
        this.buildOverview()
      }
      .width('100%').height('100%')
      .backgroundColor(AppColors.BG_SECONDARY)
    }
  }

  goBack(): void {
    NavigationUtil.back()
  }

  // ==================== 概览页 ====================

  @Builder
  buildOverview() {
    Scroll() {
      Column() {
        this.buildSummaryCard()
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

  @Builder
  buildSummaryCard() {
    Column() {
      Text('问卷统计概览')
        .fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY)
        .margin({ bottom: AppDimens.SPACE_LG })
      Row() {
        this.buildStatItem('回收', `${this.vm.getTotalResponses()}`)
        this.buildStatItem('题目', `${this.vm.questions.length}`)
        this.buildStatItem('完成率', '85%')
      }
      .width('100%').justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%').padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY).borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  @Builder
  buildStatItem(label: string, value: string) {
    Column() {
      Text(value).fontSize(AppDimens.FONT_H1).fontWeight(FontWeight.Bold).fontColor(AppColors.PRIMARY)
      Text(label).fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY).margin({ top: AppDimens.SPACE_SM })
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildQuestionCard(question: Question, index: number) {
    Column() {
      Row() {
        Text(`${index + 1}. [${QuestionTypeLabel.get(question.type) || '未知'}]`)
          .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.PRIMARY).fontWeight(FontWeight.Medium)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(AppDimens.RADIUS_PILL).backgroundColor(AppColors.PRIMARY_LIGHT)
        Blank()
        Text('查看详情 →').fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
      }
      .width('100%').margin({ bottom: AppDimens.SPACE_SM })
      Text(question.title || '未命名题目').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_PRIMARY)
    }
    .width('100%').padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY).borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
    .onClick(() => { this.selectedQuestionIndex = index })
  }

  // ==================== 逐题详情页 ====================

  @Builder
  buildQuestionDetail() {
    Scroll() {
      Column() {
        Row() {
          Text('← 返回概览').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.PRIMARY)
            .onClick(() => { this.selectedQuestionIndex = -1 })
          Blank()
        }
        .width('100%').padding({
          left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H,
          top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_SM
        })

        this.buildDetailContent()
      }
    }
    .layoutWeight(1).width('100%').scrollBar(BarState.Off)
  }

  @Builder
  buildDetailContent() {
    if (this.selectedQuestionIndex < 0 || this.selectedQuestionIndex >= this.vm.questions.length) {
      Text('题目不存在').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY)
    } else {
      Column() {
        Text(this.vm.questions[this.selectedQuestionIndex].title)
          .fontSize(AppDimens.FONT_H2).fontWeight(FontWeight.Medium).fontColor(AppColors.TEXT_PRIMARY)
          .margin({ bottom: AppDimens.SPACE_SM })

        Text(`共 ${this.vm.stats[this.selectedQuestionIndex]?.total || 0} 人次回答`)
          .fontSize(AppDimens.FONT_CAPTION).fontColor(AppColors.TEXT_TERTIARY)
          .margin({ bottom: AppDimens.SPACE_XL })

        // 按题型展示
        if (this.vm.questions[this.selectedQuestionIndex].type === QuestionType.SINGLE) {
          PieChart({
            title: '选项分布',
            data: this.vm.getPieData(this.vm.questions[this.selectedQuestionIndex]),
            total: this.vm.stats[this.selectedQuestionIndex]?.total || 0
          })
        } else if (this.vm.questions[this.selectedQuestionIndex].type === QuestionType.MULTI) {
          BarChart({
            title: '选项分布（可多选）',
            data: this.vm.getBarData(this.vm.questions[this.selectedQuestionIndex]),
            maxValue: this.vm.stats[this.selectedQuestionIndex]?.total || 1
          })
        } else if (this.vm.questions[this.selectedQuestionIndex].type === QuestionType.RATE) {
          Column() {
            Text(this.vm.getScoreSummary(this.vm.questions[this.selectedQuestionIndex]))
              .fontSize(AppDimens.FONT_H3).fontColor(AppColors.PRIMARY).fontWeight(FontWeight.Medium)
              .margin({ bottom: AppDimens.SPACE_LG })
            BarChart({
              title: '评分分布',
              data: this.vm.getScoreDistribution(this.vm.questions[this.selectedQuestionIndex]),
              maxValue: this.vm.stats[this.selectedQuestionIndex]?.total || 1
            })
          }.width('100%')
        } else if (this.vm.questions[this.selectedQuestionIndex].type === QuestionType.TEXT ||
                   this.vm.questions[this.selectedQuestionIndex].type === QuestionType.TEXTAREA) {
          this.buildTextSamples()
        } else if (this.vm.questions[this.selectedQuestionIndex].type === QuestionType.NUMBER) {
          this.buildNumberStats()
        } else {
          Text('暂无此题型的数据展示').fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_TERTIARY)
        }
      }
      .width('100%').padding(AppDimens.CARD_PADDING)
      .backgroundColor(AppColors.BG_PRIMARY).borderRadius(AppDimens.RADIUS_LG)
      .margin({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H, bottom: AppDimens.SPACE_XXL })
    }
  }

  @Builder
  buildTextSamples() {
    Column() {
      Text('回答样本').fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY).margin({ bottom: AppDimens.SPACE_MD })

      if (this.selectedQuestionIndex >= 0) {
        ForEach(this.vm.getTextSamples(this.vm.questions[this.selectedQuestionIndex]),
          (text: string) => {
            Row() {
              Text(text).fontSize(AppDimens.FONT_BODY).fontColor(AppColors.TEXT_SECONDARY).layoutWeight(1)
            }
            .width('100%').padding(AppDimens.SPACE_MD)
            .backgroundColor(AppColors.BG_GREY).borderRadius(AppDimens.RADIUS_MD)
            .margin({ bottom: AppDimens.SPACE_SM })
          })
      }
    }.width('100%')
  }

  @Builder
  buildNumberStats() {
    Column() {
      Text('数字统计').fontSize(AppDimens.FONT_H3).fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY).margin({ bottom: AppDimens.SPACE_LG })

      Row() {
        this.buildStatItem('平均', this.vm.stats[this.selectedQuestionIndex]?.avgNumber?.toFixed(1) || '-')
        this.buildStatItem('最低', this.vm.stats[this.selectedQuestionIndex]?.minNumber?.toString() || '-')
        this.buildStatItem('最高', this.vm.stats[this.selectedQuestionIndex]?.maxNumber?.toString() || '-')
      }
      .width('100%').justifyContent(FlexAlign.SpaceEvenly)
    }.width('100%')
  }
}
