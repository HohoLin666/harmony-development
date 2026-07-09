import { Questionnaire } from '../model/Questionnaire'
import { Question } from '../model/Question'
import { Option } from '../model/Question'
import { PublishStatus } from '../model/enums/PublishStatus'
import { QuestionType } from '../model/enums/QuestionType'

/**
 * Mock 数据工具 — 用于开发阶段生成测试数据
 */
export class MockDataGenerator {
  /** Mock 问卷ID列表，方便外部引用 */
  static readonly mockIds: string[] = ['q001', 'q002', 'q003']

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

  /** 根据问卷ID生成题目列表 */
  static generateQuestions(questionnaireId: string): Question[] {
    const questions: Question[] = []

    if (questionnaireId === 'q001') {
      // 员工满意度调查的题目
      questions.push(MockDataGenerator.createQuestion('1', questionnaireId, QuestionType.SINGLE,
        '你对目前的工作环境满意吗？', 0, ['非常满意', '比较满意', '一般', '不太满意', '非常不满意']))
      questions.push(MockDataGenerator.createQuestion('2', questionnaireId, QuestionType.MULTI,
        '你希望公司在哪些方面改进？（可多选）', 1, ['薪资福利', '晋升机制', '工作氛围', '培训机会', '办公设施']))
      questions.push(MockDataGenerator.createQuestion('3', questionnaireId, QuestionType.RATE,
        '你会推荐朋友来公司工作吗？（1-5分）', 2))
      questions.push(MockDataGenerator.createQuestion('4', questionnaireId, QuestionType.TEXTAREA,
        '请留下你对公司的建议', 3))
    } else if (questionnaireId === 'q002') {
      questions.push(MockDataGenerator.createQuestion('1', questionnaireId, QuestionType.SINGLE,
        '你最喜欢哪个食堂？', 0, ['一食堂', '二食堂', '三食堂', '教工食堂']))
      questions.push(MockDataGenerator.createQuestion('2', questionnaireId, QuestionType.RATE,
        '请给食堂整体卫生打分', 1))
      questions.push(MockDataGenerator.createQuestion('3', questionnaireId, QuestionType.MULTI,
        '你通常在食堂选择什么类型的菜品？（可多选）', 2, ['中式快餐', '面条/米线', '麻辣烫', '盖浇饭', '小炒']))
      questions.push(MockDataGenerator.createQuestion('4', questionnaireId, QuestionType.TEXT,
        '你还希望食堂增加什么菜品？', 3))
    } else if (questionnaireId === 'q003') {
      questions.push(MockDataGenerator.createQuestion('1', questionnaireId, QuestionType.TEXT,
        '你的姓名', 0))
      questions.push(MockDataGenerator.createQuestion('2', questionnaireId, QuestionType.SINGLE,
        '你的年级', 1, ['大一', '大二', '大三', '大四']))
      questions.push(MockDataGenerator.createQuestion('3', questionnaireId, QuestionType.MULTI,
        '你想加入什么类型的社团？（可多选）', 2, ['学术科技', '文化体育', '志愿服务', '创新创业', '其他']))
      questions.push(MockDataGenerator.createQuestion('4', questionnaireId, QuestionType.TEXTAREA,
        '请简单介绍自己的兴趣爱好', 3))
    }

    return questions
  }

  /** 创建一道题目 */
  private static createQuestion(
    id: string, questionnaireId: string, type: QuestionType,
    title: string, orderIndex: number, optionTexts?: string[]
  ): Question {
    const q = new Question()
    q.id = `${questionnaireId}_${id}`
    q.questionnaireId = questionnaireId
    q.type = type
    q.title = title
    q.orderIndex = orderIndex
    q.required = true

    if (optionTexts && (type === QuestionType.SINGLE || type === QuestionType.MULTI)) {
      optionTexts.forEach((text, i) => {
        const opt = new Option()
        opt.id = `${q.id}_opt${i}`
        opt.questionId = q.id
        opt.text = text
        opt.orderIndex = i
        q.options.push(opt)
      })
    }

    if (type === QuestionType.RATE) {
      q.maxRate = 5
    }

    return q
  }

  /** 生成唯一ID */
  static generateId(): string {
    return `${Date.now()}_${Math.random().toString(36).slice(2, 10)}`
  }
}
