import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 加载状态组件
 * @param text 加载提示文案
 */
@Component
export struct LoadingState {
  @Prop text: string = '正在加载...'

  build() {
    Column() {
      LoadingProgress()
        .width(36)
        .height(36)
        .color(AppColors.PRIMARY)

      Text(this.text)
        .fontSize(AppDimens.FONT_BODY)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ top: AppDimens.SPACE_MD })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
