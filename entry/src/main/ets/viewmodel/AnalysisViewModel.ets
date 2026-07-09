import { Questionnaire } from '../model/Questionnaire'
import { Question, Option } from '../model/Question'
import { QuestionType } from '../model/enums/QuestionType'
import { MockDataGenerator } from '../common/utils/MockData'
import { StatItem } from '../components/chart/PieChart'

/**
 * 假统计数据 — 用于 Stage 4
 */
interface FakeStats {
  /** 选项ID → 选择次数 */
  counts: Record<string, number>
  /** 总回答数 */
  total: number
  /** 填空/文本题答案列表 */
  textAnswers?: string[]
  /** 评分题平均分 */
  avgScore?: number
  /** 数字题平均/范围 */
  avgNumber?: number
  minNumber?: number
  maxNumber?: number
}

/**
 * 分析视图模型 — 加载统计数据进行可视化
 */
export class AnalysisViewModel {
  questionnaire: Questionnaire = new Questionnaire()
  questions: Question[] = []
  stats: Record<string, FakeStats> = {}
  loaded: boolean = false

  /** 加载问卷及统计数据 */
  loadData(questionnaireId: string): void {
    const allMock = MockDataGenerator.generateQuestionnaires()
    const found = allMock.find(q => q.id === questionnaireId)
    if (found) {
      this.questionnaire = found
      this.questions = MockDataGenerator.generateQuestions(questionnaireId)
      this.stats = {}
      this.questions.forEach(q => {
        this.stats[q.id] = AnalysisViewModel.generateFakeStats(q)
      })
    }
    this.loaded = true
  }

  /** 单选题 → 饼图数据 */
  getPieData(question: Question): StatItem[] {
    const stat = this.stats[question.id]
    if (!stat) return []

    const result: StatItem[] = []
    const colors = ['#1E6FFF', '#52C41A', '#FAAD14', '#FF4757', '#722ED1',
      '#13C2C2', '#EB2F96', '#FA8C16', '#2F54EB', '#A0D911']

    question.options.forEach((opt, i) => {
      const count = stat.counts[opt.id] || 0
      result.push({
        label: opt.text,
        value: count,
        percent: stat.total > 0 ? Math.round(count / stat.total * 100) : 0,
        color: colors[i % colors.length]
      })
    })
    return result
  }

  /** 多选题 → 柱状图数据 */
  getBarData(question: Question): StatItem[] {
    return this.getPieData(question) // 同样格式，用柱状图展示
  }

  /** 评分题 → 文字统计 */
  getScoreSummary(question: Question): string {
    const stat = this.stats[question.id]
    if (!stat || stat.avgScore === undefined) return ''
    return `平均分 ${stat.avgScore.toFixed(1)} / ${question.maxRate || 5}（共 ${stat.total} 人评分）`
  }

  /** 评分题 → 柱状图分布 */
  getScoreDistribution(question: Question): StatItem[] {
    const stat = this.stats[question.id]
    if (!stat) return []
    const maxRate = question.maxRate || 5
    const result: StatItem[] = []
    for (let i = 1; i <= maxRate; i++) {
      const count = stat.counts[String(i)] || 0
      result.push({
        label: `${i}分`,
        value: count,
        percent: stat.total > 0 ? Math.round(count / stat.total * 100) : 0,
        color: '#FAAD14'
      })
    }
    return result
  }

  /** 获取总回答数 */
  getTotalResponses(): number {
    return this.questionnaire.responseCount
  }

  /** 获取填空/文本题样本答案 */
  getTextSamples(question: Question): string[] {
    const stat = this.stats[question.id]
    if (!stat || !stat.textAnswers) return []
    return stat.textAnswers
  }

  // ========== 假数据生成 ==========

  private static generateFakeStats(question: Question): FakeStats {
    const total = 10 + Math.floor(Math.random() * 40)
    const stats: FakeStats = { counts: {}, total }

    if (question.type === QuestionType.SINGLE) {
      // 随机分配票数到各选项
      let remaining = total
      question.options.forEach((opt, i) => {
        if (i === question.options.length - 1) {
          stats.counts[opt.id] = remaining
        } else {
          const share = Math.floor(Math.random() * remaining * 0.6) + 1
          stats.counts[opt.id] = share
          remaining -= share
        }
      })
    } else if (question.type === QuestionType.MULTI) {
      // 多选：每个选项有概率被选中
      question.options.forEach(opt => {
        stats.counts[opt.id] = Math.floor(Math.random() * total * 0.8)
      })
    } else if (question.type === QuestionType.RATE) {
      const maxRate = question.maxRate || 5
      let remaining = total
      for (let i = 1; i <= maxRate; i++) {
        if (i === maxRate) {
          stats.counts[String(i)] = remaining
        } else {
          const share = Math.floor(Math.random() * remaining * 0.5) + 1
          stats.counts[String(i)] = share
          remaining -= share
        }
      }
      // 计算平均分
      let sum = 0
      for (let i = 1; i <= maxRate; i++) {
        sum += (stats.counts[String(i)] || 0) * i
      }
      stats.avgScore = total > 0 ? sum / total : 0
    } else if (question.type === QuestionType.TEXT || question.type === QuestionType.TEXTAREA) {
      stats.textAnswers = AnalysisViewModel.fakeTextAnswers()
    } else if (question.type === QuestionType.NUMBER) {
      stats.avgNumber = 68.5
      stats.minNumber = 12
      stats.maxNumber = 99
    }

    return stats
  }

  private static fakeTextAnswers(): string[] {
    const samples = [
      '建议增加更多下午茶选择',
      '食堂价格偏贵，希望调整',
      '整体比较满意，继续保持',
      '希望增加运动设施',
      '图书馆开放时间可以更长',
      '宿舍网络速度需要提升',
      '课程安排更灵活些',
      '社团活动更丰富就好了'
    ]
    const count = 3 + Math.floor(Math.random() * 5)
    return samples.slice(0, count)
  }
}
