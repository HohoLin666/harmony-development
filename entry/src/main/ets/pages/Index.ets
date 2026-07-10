import { AppBar } from '../components/common/AppBar'
import { TabBar, TabItem } from '../components/common/TabBar'
import { QuestionnaireCard } from '../components/common/QuestionnaireCard'
import { EmptyState } from '../components/common/EmptyState'
import { AppColors } from '../theme/AppColors'
import { AppDimens } from '../theme/AppDimens'
import { Questionnaire } from '../model/Questionnaire'
import { PublishStatus } from '../model/enums/PublishStatus'
import { NavigationUtil } from '../common/utils/NavigationUtil'
import { AuthService } from '../services/AuthService'
import { User } from '../model/User'
import { QuestionnaireStore } from '../services/QuestionnaireStore'

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
  @State username: string = ''

  aboutToAppear(): void {
    const params = NavigationUtil.getParams()
    if (params && params['tabIndex'] !== undefined) {
      this.currentTab = parseInt(params['tabIndex'] as string) || 0
    }
    this.loadData()
    this.checkLogin()
  }

  checkLogin(): void {
    AuthService.init()
    const user: User | null = AuthService.autoLogin()
    if (user) {
      this.userNickname = user.nickname
      this.username = user.username
    } else {
      NavigationUtil.replaceUrl('pages/Login')
    }
  }

  loadData(): void {
    this.publicList = QuestionnaireStore.getPublished()
    this.myDrafts = QuestionnaireStore.getMine()
  }

  build() {
    Column() {
      // 顶部导航栏
      AppBar({
        title: this.currentTab === 3 ? '我的' : (this.userNickname ? `${this.userNickname}的主页` : '问卷大厅')
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
      this.buildUserCenter()
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

  @Builder
  buildUserCenter() {
    Scroll() {
      Column() {
        this.buildProfileHeader()
        this.buildProfileInfo()
        this.buildUserMenu()
      }
      .width('100%')
      .padding({ bottom: AppDimens.SPACE_XXL })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  @Builder
  buildProfileHeader() {
    Column() {
      Stack() {
        Text(this.getAvatarText())
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_WHITE)
      }
      .width(76)
      .height(76)
      .borderRadius(38)
      .backgroundColor(AppColors.PRIMARY_DARK)
      .border({ width: 3, color: AppColors.TEXT_WHITE })
      .margin({ top: AppDimens.SPACE_XL, bottom: AppDimens.SPACE_MD })

      Text(this.userNickname || this.username || '未命名用户')
        .fontSize(AppDimens.FONT_H2)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_WHITE)
        .margin({ bottom: AppDimens.SPACE_XS })

      Text(this.username ? `账号：${this.username}` : '本地开发账号')
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor('#DCEBFF')
        .margin({ bottom: AppDimens.SPACE_LG })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(AppColors.PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  @Builder
  buildProfileInfo() {
    Row() {
      this.buildStatItem('我的创建', `${this.myDrafts.length} 份`)
      Blank()
        .width(1)
        .height(36)
        .backgroundColor(AppColors.DIVIDER)
      this.buildStatItem('我的参与', '0 份')
    }
    .width('100%')
    .padding({ top: AppDimens.SPACE_LG, bottom: AppDimens.SPACE_LG })
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
    .margin({ bottom: AppDimens.CARD_MARGIN_BOTTOM })
  }

  @Builder
  buildStatItem(title: string, value: string) {
    Column() {
      Text(value)
        .fontSize(AppDimens.FONT_H3)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(title)
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ top: AppDimens.SPACE_XS })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildUserMenu() {
    Column() {
      this.buildUserMenuItem('●', '个人信息', '查看当前账号信息', AppColors.INFO, () => {
        NavigationUtil.pushUrl('pages/ProfileEdit')
      })
      this.buildMenuDivider()
      this.buildUserMenuItem('■', '我的创建', '查看我创建的问卷', AppColors.SUCCESS, () => {
        this.currentTab = 1
      })
      this.buildMenuDivider()
      this.buildUserMenuItem('■', '我的参与', '查看我填写过的问卷', AppColors.SUCCESS, () => {
        this.currentTab = 2
      })
      this.buildMenuDivider()
      this.buildUserMenuItem('◆', '清除缓存', '清理临时缓存', AppColors.DANGER, () => {
        NavigationUtil.showDialog('清除缓存', '当前为本地开发模式，本操作不会删除账号和已创建问卷。确认清理临时缓存吗？', () => {
          NavigationUtil.showToast('缓存已清理')
        })
      })
    }
    .width('100%')
    .backgroundColor(AppColors.BG_PRIMARY)
    .borderRadius(AppDimens.RADIUS_LG)
  }

  @Builder
  buildUserMenuItem(icon: string, title: string, subtitle: string, color: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(AppDimens.FONT_BODY)
        .fontColor(color)
        .width(28)
        .textAlign(TextAlign.Center)

      Column() {
        Text(title)
          .fontSize(AppDimens.FONT_BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: AppDimens.SPACE_SM })

      Text('›')
        .fontSize(22)
        .fontColor(AppColors.TEXT_PLACEHOLDER)
    }
    .width('100%')
    .height(60)
    .padding({ left: AppDimens.SPACE_MD, right: AppDimens.SPACE_MD })
    .onClick(() => {
      onClick()
    })
  }

  @Builder
  buildMenuDivider() {
    Divider()
      .strokeWidth(1)
      .color(AppColors.DIVIDER_LIGHT)
      .margin({ left: 52 })
  }

  getAvatarText(): string {
    const name: string = this.userNickname || this.username || '我'
    return name.charAt(0)
  }
}
