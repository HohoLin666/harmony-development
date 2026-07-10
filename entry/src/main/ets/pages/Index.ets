import { AppBar } from '../components/common/AppBar'
import { TabBar, TabItem } from '../components/common/TabBar'
import { QuestionnaireCard } from '../components/common/QuestionnaireCard'
import { EmptyState } from '../components/common/EmptyState'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { Questionnaire } from '../model/Questionnaire'
import { PublishStatus } from '../model/enums/PublishStatus'
import { MockDataGenerator } from '../common/utils/MockData'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { AuthService } from '../services/AuthService'

// 底部 Tab 配置
const HOME_TABS: TabItem[] = [
  { label: '问卷大厅', icon: '', iconSymbol: '📋' },
  { label: '我的创建', icon: '', iconSymbol: '✏️' },
  { label: '我的参与', icon: '', iconSymbol: '📝' },
  { label: '我的', icon: '', iconSymbol: '👤' }
]

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State loading: boolean = false
  @State publicList: Questionnaire[] = []
  @State myDrafts: Questionnaire[] = []
  @State userNickname: string = ''

  aboutToAppear(): void {
    this.loadData()
    this.checkLogin()
  }

  checkLogin(): void {
    AuthService.init({} as Object).then(() => {
      AuthService.autoLogin().then((user) => {
        if (user) {
          this.userNickname = user.nickname
        } else {
          NavigationUtil.replaceUrl('pages/Login')
        }
      })
    })
  }

  loadData(): void {
    // Stage 1: 使用 Mock 数据（后续替换为数据库查询）
    const allMock = MockDataGenerator.generateQuestionnaires()
    this.publicList = allMock.filter(q => q.status === PublishStatus.PUBLISHED)
    this.myDrafts = allMock.filter(q => q.status === PublishStatus.DRAFT)
  }

  build() {
    Column() {
      // 顶部导航栏
      AppBar({
        title: this.userNickname ? `${this.userNickname}的主页` : '问卷大厅',
        actionText: '退出',
        onAction: () => {
          AuthService.logout().then(() => {
            NavigationUtil.replaceUrl('pages/Login')
          })
        }
      })

      // 主内容区
      Column() {
        if (this.loading) {
          Column() {
            Text('正在加载...')
              .fontSize(AppDimens.FONT_BODY)
              .fontColor(AppColors.TEXT_TERTIARY)
              .textAlign(TextAlign.Center)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height('100%')
        } else {
          this.buildTabContent()
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(AppColors.BG_SECONDARY)
      .padding({
        left: AppDimens.PAGE_PADDING_H,
        right: AppDimens.PAGE_PADDING_H,
        top: AppDimens.PAGE_PADDING_V
      })

      // 底部导航栏
      TabBar({ tabs: HOME_TABS, selectedIndex: $currentTab })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.BG_SECONDARY)
  }

  @Builder
  buildTabContent() {
    if (this.currentTab === 0) {
      this.buildPublicList()
    } else if (this.currentTab === 1) {
      this.buildMyDrafts()
    } else if (this.currentTab === 2) {
      EmptyState({ text: '你还没有参与过问卷\n去问卷大厅看看吧' })
    } else {
      EmptyState({ text: '用户中心' })
    }
  }

  /** 问卷大厅 — 公开问卷列表 */
  @Builder
  buildPublicList() {
    if (this.publicList.length === 0) {
      EmptyState({
        text: '暂无公开问卷\n去创建一份问卷吧',
        actionText: '创建问卷',
        onAction: () => {
          this.goCreate()
        }
      })
    } else {
      Stack({ alignContent: Alignment.BottomEnd }) {
        List() {
          ForEach(this.publicList, (item: Questionnaire) => {
            ListItem() {
              QuestionnaireCard({
                questionnaire: item,
                onCardClick: () => {
                  const params: Record<string, Object> = { 'questionnaireId': item.id }
                  NavigationUtil.pushUrl('pages/QuestionnaireFill', params)
                }
              })
            }
          })
        }
        .width('100%')
        .height('100%')
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)

        // FAB 创建按钮
        this.buildFAB()
      }
    }
  }

  /** 我的创建 — 草稿/我的问卷 */
  @Builder
  buildMyDrafts() {
    if (this.myDrafts.length === 0) {
      EmptyState({
        text: '你还没有创建过问卷\n点击去创建你的第一份问卷',
        actionText: '去创建',
        onAction: () => {
          this.goCreate()
        }
      })
    } else {
      Stack({ alignContent: Alignment.BottomEnd }) {
        List() {
          ForEach(this.myDrafts, (item: Questionnaire) => {
            ListItem() {
              QuestionnaireCard({
                questionnaire: item,
                onCardClick: () => {
                  // 我的问卷 → 查看数据分析
                  if (item.status === PublishStatus.PUBLISHED) {
                    const params: Record<string, Object> = { 'questionnaireId': item.id }
                    NavigationUtil.pushUrl('pages/QuestionnaireAnalysis', params)
                  } else {
                    const params: Record<string, Object> = { 'questionnaireId': item.id }
                    NavigationUtil.pushUrl('pages/QuestionnaireCreate', params)
                  }
                }
              })
            }
          })
        }
        .width('100%')
        .height('100%')
        .divider({ strokeWidth: 0 })
        .scrollBar(BarState.Off)

        // FAB 创建按钮
        this.buildFAB()
      }
    }
  }

  @Builder
  buildFAB() {
    Button('+')
      .fontSize(28)
      .fontColor(AppColors.TEXT_WHITE)
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor(AppColors.PRIMARY)
      .shadow({ radius: 8, color: 'rgba(30,111,255,0.4)', offsetY: 2 })
      .margin({ right: 0, bottom: AppDimens.SPACE_LG })
      .onClick(() => {
        this.goCreate()
      })
  }

  /** 跳转到创建页面 */
  goCreate(): void {
    NavigationUtil.pushUrl('pages/QuestionnaireCreate')
  }
}
