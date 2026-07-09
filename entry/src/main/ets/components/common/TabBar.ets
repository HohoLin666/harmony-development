import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * Tab 数据项
 */
export interface TabItem {
  label: string
  /** 系统图标/自定义图标名称 */
  icon: string
  /** 图标资源或文本符号 */
  iconSymbol: string
}

/**
 * 底部导航栏 — 4 Tab
 * @param tabIndex 当前激活的 Tab 索引
 * @param tabs Tab 数据列表
 * @param onTabChange Tab 切换回调
 */
@Component
export struct TabBar {
  @Prop tabs: TabItem[] = []
  @Link tabIndex: number
  onTabChange?: (index: number) => void

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabItem, index: number) => {
        Column() {
          Text(tab.iconSymbol)
            .fontSize(AppDimens.ICON_SIZE_LG)
            .fontColor(index === this.tabIndex ? AppColors.TAB_ACTIVE : AppColors.TAB_INACTIVE)
            .margin({ bottom: 2 })

          Text(tab.label)
            .fontSize(AppDimens.FONT_CAPTION)
            .fontColor(index === this.tabIndex ? AppColors.TAB_ACTIVE : AppColors.TAB_INACTIVE)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: AppDimens.SPACE_SM, bottom: AppDimens.SPACE_SM })
        .onClick(() => {
          this.tabIndex = index
          if (this.onTabChange) {
            this.onTabChange(index)
          }
        })
      })
    }
    .width('100%')
    .height(AppDimens.TAB_BAR_HEIGHT)
    .backgroundColor(AppColors.BG_PRIMARY)
    .padding({ bottom: 4 })
  }
}
