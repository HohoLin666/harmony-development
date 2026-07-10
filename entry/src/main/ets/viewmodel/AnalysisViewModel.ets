import { Questionnaire } from '../model/Questionnaire'
import { Question } from '../model/Question'
import { QuestionType } from '../model/enums/QuestionType'
import { StatItem } from '../components/chart/PieChart'
import { QuestionnaireStore } from '../services/QuestionnaireStore'
import { ResponseStore, ParticipationRecord } from '../services/ResponseStore'

/**
 * 真实统计数据 — 从实际提交的答案汇总
 */
class RealStats {
  counts: Map<string, number> = new Map()
  total: number = 0
  textAnswers: string[] = []
  avgScore: number = 0
}

/**
 * 分析视图模型 — 从 ResponseStore 加载真实统计数据
 */
export class AnalysisViewModel {
  questionnaire: Questionnaire = new Questionnaire()
  questions: Question[] = []
  stats: Map<string, RealStats> = new Map()
  loaded: boolean = false

  /** 加载问卷及统计数据 */
  loadData(questionnaireId: string): void {
    const found: Questionnaire | null = QuestionnaireStore.findQuestionnaire(questionnaireId)
    if (found) {
      this.questionnaire = found
      this.questions = QuestionnaireStore.getQuestions(questionnaireId)
    }
    // 从真实提交记录汇总统计
    this.stats = new Map()
    const responses: ParticipationRecord[] = ResponseStore.getByQuestionnaire(questionnaireId)
    this.questions.forEach((q: Question) => {
      this.stats.set(q.id, this.computeStats(q, responses))
    })
    // 更新问卷的回答数
    this.questionnaire.responseCount = responses.length
    this.loaded = true
  }

  /** 从真实答案计算统计 */
  private computeStats(question: Question, responses: ParticipationRecord[]): RealStats {
    const stats: RealStats = new RealStats()
    let scoreSum: number = 0
    let scoreCount: number = 0

    for (let i: number = 0; i < responses.length; i++) {
      const answer: string = responses[i].answers[question.id]
      if (!answer || answer.length === 0) continue
      stats.total++

      if (question.type === QuestionType.SINGLE) {
        // 单选：answer = optionId
        const cur: number = stats.counts.get(answer) || 0
        stats.counts.set(answer, cur + 1)
      } else if (question.type === QuestionType.MULTI) {
        // 多选：answer = JSON数组 ["opt1","opt2"]
        try {
          const arr: string[] = JSON.parse(answer)
          for (let j: number = 0; j < arr.length; j++) {
            const cur: number = stats.counts.get(arr[j]) || 0
            stats.counts.set(arr[j], cur + 1)
          }
        } catch (e) {
          // ignore
        }
      } else if (question.type === QuestionType.RATE) {
        // 评分：answer = "4"
        const score: number = parseInt(answer)
        if (!isNaN(score)) {
          const key: string = String(score)
          const cur: number = stats.counts.get(key) || 0
          stats.counts.set(key, cur + 1)
          scoreSum += score
          scoreCount++
        }
      } else if (question.type === QuestionType.TEXT || question.type === QuestionType.TEXTAREA) {
        // 文本：收集原文
        stats.textAnswers.push(answer)
      }
    }

    // 评分题计算平均分
    if (question.type === QuestionType.RATE && scoreCount > 0) {
      stats.avgScore = scoreSum / scoreCount
    }

    return stats
  }

  /** 单选题 → 饼图数据 */
  getPieData(question: Question): StatItem[] {
    const stat: RealStats | undefined = this.stats.get(question.id)
    if (!stat) return []

    const result: StatItem[] = []
    const colors: string[] = ['#1E6FFF', '#52C41A', '#FAAD14', '#FF4757', '#722ED1',
      '#13C2C2', '#EB2F96', '#FA8C16', '#2F54EB', '#A0D911']

    question.options.forEach((opt, i: number) => {
      const count: number = stat.counts.get(opt.id) || 0
      const item: StatItem = new StatItem()
      item.label = opt.text || `选项${i + 1}`
      item.value = count
      item.percent = stat.total > 0 ? Math.round(count / stat.total * 100) : 0
      item.color = colors[i % colors.length]
      result.push(item)
    })
    return result
  }

  /** 多选题 → 柱状图数据 */
  getBarData(question: Question): StatItem[] {
    return this.getPieData(question)
  }

  /** 评分题 → 文字统计 */
  getScoreSummary(question: Question): string {
    const stat: RealStats | undefined = this.stats.get(question.id)
    if (!stat || stat.total === 0) return '暂无评分数据'
    return `平均分 ${stat.avgScore.toFixed(1)} / ${question.maxRate || 5}（共 ${stat.total} 人评分）`
  }

  /** 评分题 → 柱状图分布 */
  getScoreDistribution(question: Question): StatItem[] {
    const stat: RealStats | undefined = this.stats.get(question.id)
    if (!stat) return []
    const maxRate: number = question.maxRate || 5
    const result: StatItem[] = []
    for (let i: number = 1; i <= maxRate; i++) {
      const count: number = stat.counts.get(String(i)) || 0
      const item: StatItem = new StatItem()
      item.label = `${i}分`
      item.value = count
      item.percent = stat.total > 0 ? Math.round(count / stat.total * 100) : 0
      item.color = '#FAAD14'
      result.push(item)
    }
    return result
  }

  /** 获取总回答数 */
  getTotalResponses(): number {
    return this.questionnaire.responseCount
  }

  /** 获取填空/文本题样本答案 */
  getTextSamples(question: Question): string[] {
    const stat: RealStats | undefined = this.stats.get(question.id)
    if (!stat || stat.textAnswers.length === 0) return []
    return stat.textAnswers
  }
}
