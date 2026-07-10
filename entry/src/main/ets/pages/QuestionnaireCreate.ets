import { AppBar } from '../components/common/AppBar'
import { QuestionEditor } from '../components/editor/QuestionEditor'
import { QuestionTypePicker } from '../components/editor/QuestionTypePicker'
import { PrimaryButton } from '../components/common/PrimaryButton'
import { CreateViewModel } from '../viewmodel/CreateViewModel'
import { Question } from '../model/Question'
import { QuestionType } from '../model/enums/QuestionType'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { IdGenerator } from '../common/utils/IdGenerator'

/**
 * 创建/编辑问卷页
 * Stage 2: 完整创建流程 — 基本信息 + 题目编辑器 + 题型选择 + 保存/发布
 */
@Entry
@Component
struct QuestionnaireCreate {
  @State vm: CreateViewModel = new CreateViewModel()
  @State questions: Question[] = []
  @State showTypePicker: boolean = false
  @State editingQuestionIndex: number = -1

  aboutToAppear(): void {
    this.vm.initNew()
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        // 顶部导航栏
        AppBar({
          title: this.vm.isEditing ? '编辑问卷' : '创建问卷',
          showBack: true,
          onBack: () => {
            NavigationUtil.back()
          }
        })

        // 主内容区 (可滚动)
        Scroll() {
          Column() {
            // 问卷基本信息区域
            this.buildBasicInfo()

            // 分割线
            Divider()
              .strokeWidth(1)
              .color(AppColors.DIVIDER)
              .margin({ left: AppDimens.CARD_PADDING, right: AppDimens.CARD_PADDING })

            // 题目列表
            this.buildQuestionList()

            // 添加题目按钮
            this.buildAddQuestionButton()

            // 操作按钮区域
            this.buildActions()
          }
          .padding({
            left: AppDimens.PAGE_PADDING_H,
            right: AppDimens.PAGE_PADDING_H,
            top: AppDimens.PAGE_PADDING_V,
            bottom: AppDimens.SPACE_XXL + 48
          })
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor(AppColors.BG_SECONDARY)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')

      // 题型选择弹窗 (底部弹出)
      if (this.showTypePicker) {
        QuestionTypePicker({
          visible: this.showTypePicker,
          onSelect: (type: QuestionType) => {
            if (this.editingQuestionIndex >= 0) {
              this.questions[this.editingQuestionIndex].type = type
              this.questions = [...this.questions]
              this.editingQuestionIndex = -1
            } else {
              this.vm.addQuestion(type)
              this.questions = [...this.vm.questions]
            }
            this.showTypePicker = false
          },
          onClose: () => {
            this.showTypePicker = false
            this.editingQuestionIndex = -1
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 问卷基本信息 ====================

  @Builder
  buildBasicInfo() {
    Column() {
      // 标题
      TextInput({ placeholder: '请输入问卷标题', text: this.vm.questionnaire.title })
        .fontSize(AppDimens.FONT_H2)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY)
        .placeholderColor(AppColors.TEXT_PLACEHOLDER)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding({ top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_SM })
        .onChange((value: string) => {
          this.vm.questionnaire.title = value
        })

      // 描述
      TextInput({ placeholder: '添加问卷描述（选填）', text: this.vm.questionnaire.description })
        .fontSize(AppDimens.FONT_BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .placeholderColor(AppColors.TEXT_PLACEHOLDER)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding({ top: AppDimens.SPACE_SM, bottom: AppDimens.SPACE_MD })
        .onChange((value: string) => {
          this.vm.questionnaire.description = value
        })
    }
    .width('100%')
    .padding(AppDimens.CARD_PADDING)
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  // ==================== 题目列表 ====================

  @Builder
  buildQuestionList() {
    if (this.questions.length > 0) {
      ForEach(this.questions, (question: Question, index: number) => {
        QuestionEditor({
          question: question,
          index: index + 1,
          onDelete: () => {
            this.vm.removeQuestion(index)
            this.questions = [...this.vm.questions]
          },
          onChangeType: () => {
            this.editingQuestionIndex = index
            this.showTypePicker = true
          }
        })
      }, (question: Question) => question.id)
    } else {
      // 空提示
      Column() {
        Text('还没有题目')
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.TEXT_TERTIARY)
          .margin({ top: AppDimens.SPACE_XL, bottom: AppDimens.SPACE_MD })
        Text('点击下方按钮添加题目')
          .fontSize(AppDimens.FONT_CAPTION)
          .fontColor(AppColors.TEXT_PLACEHOLDER)
      }
      .width('100%')
      .padding({ top: AppDimens.SPACE_XXL, bottom: AppDimens.SPACE_XXL })
      .alignItems(HorizontalAlign.Center)
    }
  }

  // ==================== 添加题目按钮 ====================

  @Builder
  buildAddQuestionButton() {
    Column() {
      Row() {
        Text('+')
          .fontSize(AppDimens.FONT_LARGE)
          .fontColor(AppColors.PRIMARY)
          .margin({ right: AppDimens.SPACE_SM })
        Text('添加题目')
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(AppColors.BG_PRIMARY)
      .borderRadius(AppDimens.RADIUS_MD)
      .border({ width: 1, color: AppColors.PRIMARY, style: BorderStyle.Dashed })
      .onClick(() => {
        this.editingQuestionIndex = -1 // 新增模式
        this.showTypePicker = true
      })
    }
    .width('100%')
    .margin({ top: AppDimens.SPACE_MD, bottom: AppDimens.SPACE_LG })
  }

  // ==================== 操作按钮 ====================

  @Builder
  buildActions() {
    Column() {
      Row() {
        // 保存草稿
        Button('保存草稿')
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.PRIMARY)
          .backgroundColor(AppColors.BG_PRIMARY)
          .border({ width: 1, color: AppColors.PRIMARY })
          .borderRadius(AppDimens.RADIUS_PILL)
          .height(AppDimens.BUTTON_HEIGHT)
          .layoutWeight(1)
          .margin({ right: AppDimens.SPACE_MD })
          .onClick(() => {
            this.handleSave()
          })

        // 发布/预览
        PrimaryButton({
          text: '发布问卷',
          disabled: false,
          onButtonClick: () => {
            this.handlePublish()
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: AppDimens.SPACE_MD })
  }

  // ==================== 业务逻辑 ====================

  /** 保存草稿 */
  handleSave(): void {
    const result = this.vm.saveDraft()
    if (result) {
      NavigationUtil.showToast('已保存草稿')
      // TODO: 写入数据库后返回首页
    } else {
      NavigationUtil.showToast('请填写问卷标题')
    }
  }

  /** 发布问卷 */
  handlePublish(): void {
    const validation = this.vm.validate()
    if (!validation.valid) {
      NavigationUtil.showToast(validation.message)
      return
    }
    this.vm.publish()
    NavigationUtil.showToast('发布成功')
    // TODO: 写入数据库后返回首页
    // router.back()
  }
}
