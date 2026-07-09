import { AppColors } from '../../theme/AppColors'
import { AppDimens } from '../../theme/AppDimens'

/**
 * 统计项
 */
export class StatItem {
  label: string = ''
  value: number = 0
  percent: number = 0
  color: string = ''
}

/** 饼图配色 */
const PIE_COLORS: string[] = [
  '#1E6FFF', '#52C41A', '#FAAD14', '#FF4757', '#722ED1',
  '#13C2C2', '#EB2F96', '#FA8C16', '#2F54EB', '#A0D911'
]

/**
 * 饼图组件 — 用进度条实现
 * 每个选项 = 一条颜色条 + 标签 + 百分比 + 数值
 */
@Component
export struct PieChart {
  @Prop title: string = ''
  @Prop data: StatItem[] = []
  @Prop total: number = 0

  build() {
    Column() {
      if (this.title) {
        Text(this.title)
          .fontSize(AppDimens.FONT_H3)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ bottom: AppDimens.SPACE_LG })
      }

      ForEach(this.data, (item: StatItem) => {
        Column() {
          Row() {
            Text(item.label)
              .fontSize(AppDimens.FONT_BODY)
              .fontColor(AppColors.TEXT_PRIMARY)
              .layoutWeight(1)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(`${item.value} (${item.percent}%)`)
              .fontSize(AppDimens.FONT_CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
              .margin({ left: AppDimens.SPACE_SM })
          }
          .width('100%')
          .margin({ bottom: AppDimens.SPACE_SM })

          // 颜色进度条
          Row() {
            Blank()
          }
          .width(`${item.percent}%`)
          .height(10)
          .backgroundColor(item.color)
          .borderRadius(AppDimens.RADIUS_SM)
          .animation({ duration: 500, curve: Curve.EaseOut })
        }
        .width('100%')
        .margin({ bottom: AppDimens.SPACE_MD })
      })
    }
    .width('100%')
  }
}

/**
 * 柱状图组件 — 垂直柱形
 * 每个选项 = 一个柱子 + 标签 + 数值
 */
@Component
export struct BarChart {
  @Prop title: string = ''
  @Prop data: StatItem[] = []
  @Prop maxValue: number = 0

  build() {
    Column() {
      if (this.title) {
        Text(this.title)
          .fontSize(AppDimens.FONT_H3)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ bottom: AppDimens.SPACE_LG })
      }

      // 柱形行
      Row() {
        ForEach(this.data, (item: StatItem) => {
          Column() {
            Text(String(item.value))
              .fontSize(AppDimens.FONT_CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
              .margin({ bottom: AppDimens.SPACE_SM })

            // 柱子
            Column() {
              Blank()
            }
            .width(36)
            .height(this.getBarHeight(item.value))
            .backgroundColor(item.color)
            .borderRadius({ topLeft: AppDimens.RADIUS_SM, topRight: AppDimens.RADIUS_SM })
            .animation({ duration: 500, curve: Curve.EaseOut })

            Text(item.label)
              .fontSize(AppDimens.FONT_CAPTION)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ top: AppDimens.SPACE_SM })
              .maxLines(1)
              .width(60)
              .textAlign(TextAlign.Center)
          }
          .alignItems(HorizontalAlign.Center)
          .margin({ right: AppDimens.SPACE_MD })
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
  }

  private getBarHeight(value: number): number {
    if (this.maxValue <= 0) return 10
    return Math.max(10, Math.round(value / this.maxValue * 120))
  }
}

/**
 * 生成饼图数据
 */
export function toPieData(
  labels: string[],
  values: number[],
  total: number
): StatItem[] {
  const result: StatItem[] = []
  labels.forEach((label, i) => {
    const item = new StatItem()
    item.label = label
    item.value = values[i] || 0
    item.percent = total > 0 ? Math.round((values[i] || 0) / total * 100) : 0
    item.color = PIE_COLORS[i % PIE_COLORS.length]
    result.push(item)
  })
  return result
}
