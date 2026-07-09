/**
 * 答卷实体
 */
export class Response {
  id: string = ''
  questionnaireId: string = ''
  userId: string = ''
  deviceId: string = ''
  /** 填写耗时(毫秒) */
  duration: number = 0
  submittedAt: number = Date.now()
}

/**
 * 答案实体
 */
export class Answer {
  id: string = ''
  responseId: string = ''
  questionId: string = ''
  /** 答案值（JSON字符串：单选存OptionId，多选存数组，填空存文本） */
  value: string = ''
  createdAt: number = Date.now()
}
