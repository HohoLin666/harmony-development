import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'
import { DistributedService } from '../../services/DistributedService'

/**
 * 协同状态栏 — 显示多设备协同连接状态
 * 当检测到分布式连接时在页面顶部显示
 */
@Component
export struct CollaborativeBar {
  @Prop visible: boolean = false

  build() {
    if (!this.visible) return

    Row() {
      Text('🔗')
        .fontSize(14)
        .margin({ right: AppDimens.SPACE_SM })
      Text('多设备协同已开启')
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.PRIMARY)
      Blank()
      Text('关闭')
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
        .onClick(() => {
          DistributedService.endCollaboration()
        })
    }
    .width('100%')
    .height(36)
    .backgroundColor(AppColors.PRIMARY_LIGHT)
    .padding({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H })
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}

/**
 * 协同填写状态提示 — 在填写页面底部展示
 */
@Component
export struct SyncStatusBar {
  @Prop connected: boolean = false
  @Prop completedCount: number = 0
  @Prop totalCount: number = 0

  build() {
    if (!this.connected) return

    Row() {
      Text('📱')
        .fontSize(14)
        .margin({ right: AppDimens.SPACE_SM })
      Text(`多设备同步中 · ${this.completedCount}/${this.totalCount}`)
        .fontSize(AppDimens.FONT_CAPTION)
        .fontColor(AppColors.PRIMARY)
    }
    .width('100%')
    .padding({ left: AppDimens.PAGE_PADDING_H, right: AppDimens.PAGE_PADDING_H, top: 6, bottom: 6 })
    .backgroundColor(AppColors.PRIMARY_LIGHT)
  }
}
