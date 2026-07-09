import { Questionnaire } from '../model/Questionnaire'
import { Question } from '../model/Question'
import { Option } from '../model/Question'
import { PublishStatus } from '../model/enums/PublishStatus'
import { QuestionType } from '../model/enums/QuestionType'

/**
 * Mock 数据工具 — 用于开发阶段生成测试数据
 */
export class MockDataGenerator {
  /** 创建模拟问卷列表 */
  static generateQuestionnaires(): Questionnaire[] {
    const mockList: Questionnaire[] = []

    // 问卷 1：已发布
    const q1 = new Questionnaire()
    q1.id = 'q001'
    q1.title = '2024年度员工满意度调查'
    q1.description = '为了更好地了解员工的工作满意度，请如实填写以下问卷，您的反馈将帮助我们改进。'
    q1.status = PublishStatus.PUBLISHED
    q1.questionCount = 15
    q1.responseCount = 128
    q1.creatorName = 'HR部门'
    q1.createdAt = Date.now() - 7 * 24 * 60 * 60 * 1000
    mockList.push(q1)

    // 问卷 2：已发布
    const q2 = new Questionnaire()
    q2.id = 'q002'
    q2.title = '校园食堂菜品满意度调研'
    q2.description = '选出你最满意的食堂档口，帮助我们优化菜品供应！'
    q2.status = PublishStatus.PUBLISHED
    q2.questionCount = 10
    q2.responseCount = 356
    q2.creatorName = '学生会'
    q2.createdAt = Date.now() - 3 * 24 * 60 * 60 * 1000
    mockList.push(q2)

    // 问卷 3：草稿
    const q3 = new Questionnaire()
    q3.id = 'q003'
    q3.title = '社团招新报名表'
    q3.description = '欢迎报名参加本学期的社团活动'
    q3.status = PublishStatus.DRAFT
    q3.questionCount = 8
    q3.responseCount = 0
    q3.creatorName = '我'
    q3.createdAt = Date.now() - 1 * 24 * 60 * 60 * 1000
    mockList.push(q3)

    return mockList
  }

  /** 生成唯一ID */
  static generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).slice(2, 10)}`
  }
}
