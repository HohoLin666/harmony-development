# 鸿蒙版在线问卷调查系统 — 架构规划文档

> 风格参考：选题文档中的问卷类小程序截图（蓝白配色 + 底部导航 + 卡片化布局）

---

## 一、整体设计风格

### 1.1 视觉风格

| 维度 | 规范 | 参考图特征 |
|---|---|---|
| **主色调** | 蓝白配色（`#1E6FFF` 标题栏 / `#FFFFFF` 内容区） | 顶栏实色蓝，内容卡白色 |
| **辅助色** | 文字主色 `#333`、次要 `#999`、分割线 `#E5E5E5` | 灰阶分明 |
| **强调色** | CTA 按钮蓝（`#1E6FFF`）、已选中红点（`#FF4757`） | 红色用于未读提示 |
| **圆角** | 卡片 8-12px、按钮 20-24px、输入框 4-6px | 现代圆润 |
| **字号层级** | 标题 18sp / 副标题 16sp / 正文 14sp / 辅助 12sp | 经典四档 |
| **间距** | 卡片外边距 16px、卡片内边距 16px、元素间距 12px | 16 进制节奏 |
| **底部导航** | 4 个 Tab：问卷大厅 / 我的创建 / 我的参与 / 我的 | 标配 |
| **顶部导航** | 居中标题 + 右上角三点菜单（小程序胶囊） | 经典微信范 |
| **空状态** | 居中插画 + 提示文案 + 行动按钮（如"去参与问卷吧"） | 友好引导 |
| **加载状态** | 转圈 + "正在加载" 文本 | 简洁 |

### 1.2 交互风格

- **卡片化布局**：所有列表项都是白色圆角卡片
- **Tab 切换**：顶部 Tab 切换 + 蓝色下划线指示器
- **FAB 浮动按钮**：右下角"+创建"按钮（如需要）
- **下拉刷新 + 上拉加载**：标准列表行为
- **轻提示 Toast**：操作反馈用 Toast 而非弹窗

---

## 二、目录结构（按风格模块化组织）

```
entry/src/main/ets/
│
├── pages/                          # 页面层
│   ├── Index.ets                   # 首页（问卷大厅）
│   ├── QuestionnaireCreate.ets     # 创建问卷
│   ├── QuestionnaireEdit.ets       # 编辑问卷
│   ├── QuestionnaireFill.ets       # 填写问卷
│   ├── QuestionnaireAnalysis.ets   # 数据分析
│   ├── QuestionnairePreview.ets    # 问卷预览
│   ├── MyCreated.ets               # 我的创建
│   ├── MyParticipated.ets          # 我的参与
│   └── UserCenter.ets              # 我的（用户中心）
│
├── components/                     # 组件层（按业务域分组）
│   │
│   ├── common/                     # 通用基础组件
│   │   ├── AppBar.ets              # 顶部导航栏（蓝底白字）
│   │   ├── TabBar.ets              # 底部导航栏（4 Tab）
│   │   ├── TopTab.ets              # 顶部 Tab 切换
│   │   ├── QuestionnaireCard.ets    # 问卷卡片
│   │   ├── PrimaryButton.ets       # 主按钮（蓝色圆角）
│   │   ├── EmptyState.ets          # 空状态（插画+提示+按钮）
│   │   ├── LoadingState.ets        # 加载状态
│   │   └── Toast.ets               # 轻提示
│   │
│   ├── question/                   # 题型组件（动态表单）
│   │   ├── QuestionRenderer.ets    # 题型分发器
│   │   ├── SingleChoice.ets        # 单选
│   │   ├── MultiChoice.ets         # 多选
│   │   ├── TextFill.ets            # 填空
│   │   ├── RateScore.ets           # 评分
│   │   ├── MatrixQuestion.ets      # 矩阵
│   │   └── DatePicker.ets          # 日期
│   │
│   ├── editor/                     # 编辑器组件
│   │   ├── QuestionEditor.ets      # 题目编辑器
│   │   ├── OptionEditor.ets        # 选项编辑
│   │   ├── QuestionTypeSelector.ets # 题型选择
│   │   └── LogicJumpEditor.ets     # 逻辑跳转
│   │
│   └── chart/                      # 图表组件
│       ├── PieChart.ets            # 饼图
│       ├── BarChart.ets            # 柱状图
│       └── LineChart.ets           # 折线图
│
├── model/                          # 数据模型
│   ├── Questionnaire.ets           # 问卷
│   ├── Question.ets                # 题目
│   ├── Option.ets                  # 选项
│   ├── Response.ets                # 答卷
│   ├── Answer.ets                  # 答案
│   └── enums/
│       ├── QuestionType.ets
│       └── PublishStatus.ets
│
├── viewmodel/                      # 视图模型（MVVM）
│   ├── HomeViewModel.ets
│   ├── CreateViewModel.ets
│   ├── FillViewModel.ets
│   ├── AnalysisViewModel.ets
│   └── MyViewModel.ets
│
├── data/                           # 数据层
│   ├── DatabaseHelper.ets          # 数据库初始化
│   ├── QuestionnaireDao.ets        # 问卷数据访问
│   ├── AnswerDao.ets               # 答案数据访问
│   └── DistributedHelper.ets       # 分布式数据库
│
├── services/                       # 业务服务
│   ├── QuestionnaireService.ets
│   ├── StatisticService.ets
│   ├── ShareService.ets
│   └── DistributedService.ets
│
├── theme/                          # 主题与样式
│   ├── AppColors.ets               # 颜色常量
│   ├── AppFonts.ets                # 字体常量
│   ├── AppDimens.ets               # 尺寸常量
│   └── AppStyles.ets               # 通用样式
│
└── common/                         # 工具
    ├── IdGenerator.ets
    ├── DateUtil.ets
    ├── Validator.ets
    └── Logger.ets
```

---

## 三、核心数据模型

```
Questionnaire (问卷)
├── id, title, description
├── creatorId, creatorName
├── status: DRAFT / PUBLISHED / CLOSED
├── questionCount, responseCount
├── deadline?, shareToken
└── createdAt, updatedAt

Question (题目)
├── id, questionnaireId
├── type: SINGLE / MULTI / TEXT / RATE / MATRIX / DATE
├── title, required
├── options[] (单选/多选/矩阵)
├── logicJump? (条件显示/跳过)
└── orderIndex

Option (选项)
├── id, questionId
├── text, orderIndex
└── isCustom (是否"其他"自定义)

Response (答卷)
├── id, questionnaireId
├── userId, deviceId
├── duration (填写耗时)
└── submittedAt

Answer (答案)
├── id, responseId, questionId
├── value: string | string[] (JSON存储)
└── createdAt
```

---

## 四、页面路由

| 路由 | 页面 | 入口 |
|---|---|---|
| `pages/Index` | 问卷大厅 | 启动入口 |
| `pages/QuestionnaireCreate` | 创建问卷 | 大厅 + / 浮动按钮 |
| `pages/QuestionnaireEdit` | 编辑问卷 | 我的创建 → 列表项 |
| `pages/QuestionnairePreview` | 问卷预览 | 编辑页 → 预览 |
| `pages/QuestionnaireFill` | 填写问卷 | 大厅卡片 / 分享链接 |
| `pages/QuestionnaireAnalysis` | 数据分析 | 我的创建 → 已发布 |
| `pages/MyCreated` | 我的创建 | 底部 Tab |
| `pages/MyParticipated` | 我的参与 | 底部 Tab |
| `pages/UserCenter` | 我的 | 底部 Tab |

**Tab 导航**（AppBar 内部 + TabBar 外部）：
- 问卷大厅（首页）— TabBar 第 1 项
- 我的创建 — TabBar 第 2 项
- 我的参与 — TabBar 第 3 项
- 我的 — TabBar 第 4 项

---

## 五、UI 组件复用清单

### 5.1 必须有的公共组件

| 组件 | 用途 | 关键属性 |
|---|---|---|
| `AppBar` | 顶部蓝色导航栏 | title, showBack, showMore |
| `TabBar` | 底部 4 Tab 导航 | activeIndex, onChange |
| `TopTab` | 顶部 Tab 切换 | tabs[], activeIndex |
| `QuestionnaireCard` | 问卷列表卡片 | title, cover, count, status |
| `PrimaryButton` | 主操作按钮 | text, onClick, disabled |
| `EmptyState` | 空状态 | icon, text, actionText |
| `LoadingState` | 加载中 | text |

### 5.2 题型组件（动态渲染）

通过 JSON Schema 驱动 `QuestionRenderer` 分发：

```typescript
QuestionRenderer({ question: Question })
  ├── type === 'SINGLE'  → SingleChoice
  ├── type === 'MULTI'   → MultiChoice
  ├── type === 'TEXT'    → TextFill
  ├── type === 'RATE'    → RateScore
  ├── type === 'MATRIX'  → MatrixQuestion
  └── type === 'DATE'    → DatePicker
```

---

## 六、关键功能实现要点

### 6.1 动态表单生成器（核心亮点）

```typescript
// QuestionType 枚举
enum QuestionType {
  SINGLE = 'single',      // 单选
  MULTI = 'multi',        // 多选
  TEXT = 'text',          // 填空
  TEXTAREA = 'textarea',  // 长文本
  RATE = 'rate',          // 评分
  MATRIX = 'matrix',      // 矩阵
  DATE = 'date',          // 日期
  NUMBER = 'number'       // 数字
}

// Question 模型
class Question {
  id: string
  type: QuestionType
  title: string
  required: boolean = false
  options?: Option[]      // 单选/多选/矩阵
  logicJump?: LogicJump   // 逻辑跳转
  validation?: Validation // 校验规则
  orderIndex: number
}
```

### 6.2 多设备协同填写（差异化亮点）

基于 `distributedDataObject`：
- 不同设备（手机/平板）登录同一账号后，自动同步问卷草稿和填写进度
- 平板可实时预览手机端填写的状态
- 一键"接力填写"：手机答一半，平板续答

### 6.3 数据可视化

通过 `@ohos.chart` 实现：
- **饼图**：单选/多选各选项占比
- **柱状图**：评分题分布
- **折线图**：答题时间趋势
- **交叉分析**：多维度对比（如"年龄段 × 满意度"）

### 6.4 分享传播

通过 `systemShare` 组件：
- 生成问卷短链（如 `harmony://questionnaire/{id}`）
- 一键分享到微信/QQ/短信
- 分享卡片显示问卷标题、描述、缩略图

---

## 七、开发阶段规划（建议 6 周）

| 阶段 | 周次 | 内容 | 交付物 |
|---|---|---|---|
| **Stage 1** 数据基础 | Week 1 | 数据模型 + 数据库 + DAO | 问卷 CRUD |
| **Stage 2** UI 框架 | Week 1-2 | 公共组件 + 主题 + 路由 | AppBar/TabBar/EmptyState 等可复用组件 |
| **Stage 3** 创建问卷 | Week 2-3 | 编辑器 + 题型组件 + 逻辑跳转 | 能创建完整问卷 |
| **Stage 4** 填写问卷 | Week 3-4 | 填写页 + 题型渲染 + 提交 | 能填写并提交 |
| **Stage 5** 数据分析 | Week 4-5 | Chart 可视化 + 统计服务 | 数据图表 |
| **Stage 6** 多端协同 | Week 5-6 | 分布式同步 + 分享 + 推送 | 完整闭环 |

---

## 八、配色与字体常量（建议统一封装）

```typescript
// AppColors.ets
export class AppColors {
  // 主色
  static readonly PRIMARY = '#1E6FFF'        // 主题蓝
  static readonly PRIMARY_DARK = '#0D5BD9'
  static readonly PRIMARY_LIGHT = '#E8F0FF'

  // 功能色
  static readonly SUCCESS = '#52C41A'
  static readonly WARNING = '#FAAD14'
  static readonly DANGER = '#FF4757'
  static readonly INFO = '#909399'

  // 文字
  static readonly TEXT_PRIMARY = '#333333'
  static readonly TEXT_SECONDARY = '#666666'
  static readonly TEXT_TERTIARY = '#999999'
  static readonly TEXT_PLACEHOLDER = '#BBBBBB'

  // 背景
  static readonly BG_PRIMARY = '#FFFFFF'
  static readonly BG_SECONDARY = '#F5F7FA'
  static readonly BG_GREY = '#F0F2F5'

  // 分割线
  static readonly DIVIDER = '#E5E5E5'
}

// AppDimens.ets
export class AppDimens {
  static readonly SPACE_XS = 4
  static readonly SPACE_SM = 8
  static readonly SPACE_MD = 12
  static readonly SPACE_LG = 16
  static readonly SPACE_XL = 24
  static readonly SPACE_XXL = 32

  static readonly RADIUS_SM = 4
  static readonly RADIUS_MD = 8
  static readonly RADIUS_LG = 12
  static readonly RADIUS_PILL = 20

  static readonly FONT_H1 = 20
  static readonly FONT_H2 = 18
  static readonly FONT_H3 = 16
  static readonly FONT_BODY = 14
  static readonly FONT_CAPTION = 12
}
```

---

## 九、接下来的实施建议

1. **第一周**：先把 `theme/`、`components/common/`、`pages/Index` 三个目录搭起来，跑通"AppBar + TabBar + 问卷列表卡片 + 空状态"这个最小可见闭环
2. **第二周**：把 `data/` 层的 SQLite 跑通，能在首页看到从数据库读出来的问卷列表
3. **第三周起**：按 Stage 3-6 推进

> **原则**：每个阶段都必须有一个能跑通的可见功能（垂直切片），不要等所有底层都做完才出 UI。

---

*文档生成时间：2026-07-09*
