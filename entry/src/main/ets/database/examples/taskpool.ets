import { common } from '@kit.AbilityKit'
import { taskpool } from '@kit.ArkTS'
import { Article, TAG, ArticlePayload } from '../models/Article'
import { ArticleData } from '../models/ArticleData'



@Concurrent
async function query(context: common.Context): Promise<Array<Article>> {
  return await ArticleData.getInstance().queryArticle(context)
}

@Concurrent
async function queryPhone(context: common.Context, phone: string): Promise<Array<Article>> {
  return await ArticleData.getInstance().queryPhoneArticle(context, phone)
}

@Concurrent
async function queryLike(context: common.Context, content: string): Promise<Array<Article>> {
  return await ArticleData.getInstance().queryLIkeArticle(context, content)
}

@Concurrent
async function addUser(context: common.Context, article: Article | ArticlePayload) {
  return await ArticleData.getInstance().addArticle(context, article)
}

@Concurrent
async function deleteData(context: common.Context, id: number) {
  return await ArticleData.getInstance().deleteArticle(context, id)
}

@Concurrent
async function upData(context: common.Context, article: Article | ArticlePayload) {
  return await ArticleData.getInstance().updateArticle(context, article)
}

export async function taskPoolExecuteQuery(context: common.Context): Promise<Array<Article>> {
  try {
    const task: taskpool.Task = new taskpool.Task(query, context)
    const result: Array<Article> = await taskpool.execute(task) as Array<Article>
    console.info(TAG, `taskpool执行查询完毕，结果：${JSON.stringify(result)}`)
    return result
  } catch (err) {
    console.error(TAG, `taskpool执行查询出现错误：${JSON.stringify(err)}`)
    return []
  }
}

export async function taskPoolExecuteQueryPhone(context: common.Context, phone: string): Promise<Array<Article>> {
  try {
    const task: taskpool.Task = new taskpool.Task(queryPhone, context, phone)
    const result: Array<Article> = await taskpool.execute(task) as Array<Article>
    console.info(TAG, `taskpool执行查询完毕，结果：${JSON.stringify(result)}`)
    return result
  } catch (err) {
    console.error(TAG, `taskpool执行查询出现错误：${JSON.stringify(err)}`)
    return []
  }
}

export async function taskPoolExecuteQueryLike(context: common.Context, content: string): Promise<Array<Article>> {
  try {
    const task: taskpool.Task = new taskpool.Task(queryLike, context, content)
    const result: Array<Article> = await taskpool.execute(task) as Array<Article>
    console.info(TAG, `taskpool执行查询完毕，结果：${JSON.stringify(result)}`)
    return result
  } catch (err) {
    console.error(TAG, `taskpool执行查询出现错误：${JSON.stringify(err)}`)
    return []
  }
}

export async function taskPoolExecuteInsert(context: common.Context, article: Article | ArticlePayload) {
  try {
    const task: taskpool.Task = new taskpool.Task(addUser, context, article)
    await taskpool.execute(task)
    console.info(TAG, `taskpool执行插入完毕`)
  } catch (err) {
    console.error(TAG, `taskpool执行插入出现错误：${JSON.stringify(err)}`)
  }
}

export async function taskPoolExecuteUpdate(context: common.Context, contact: Article | ArticlePayload) {
  try {
    const task: taskpool.Task = new taskpool.Task(upData, context, contact)
    await taskpool.execute(task)
    console.info(TAG, `taskpool执行更新完毕`)
  } catch (err) {
    console.error(TAG, `taskpool执行更新出现错误：${JSON.stringify(err)}`)
  }
}

export async function taskPoolExecuteDelete(context: common.Context, id: number) {
  try {
    const task: taskpool.Task = new taskpool.Task(deleteData, context, id)
    await taskpool.execute(task)
    console.info(TAG, `taskpool执行删除完毕`)
  } catch (err) {
    console.error(TAG, `taskpool执行删除出现错误：${JSON.stringify(err)}`)
  }
}
