import { common } from '@kit.AbilityKit'
import { relationalStore } from '@kit.ArkData'
import { IBestORMInit, GetIBestORM } from '../orm'
import { Article, TAG, ArticlePayload } from './Article'

const STORE_CONFIG_ARTICLE: relationalStore.StoreConfig = { name: 'article.db', securityLevel: relationalStore.SecurityLevel.S2 }

export class ArticleData {
  private static instance: ArticleData | undefined = undefined
  private initialized: boolean = false
  
  private toBucket(input: Article | ArticlePayload): relationalStore.ValuesBucket {
    const bucket: relationalStore.ValuesBucket = {}
    const p = input as ArticlePayload
    const a = input as Article
    if (p.title !== undefined || p.contentStr !== undefined || p.userImage !== undefined) {
      if (p.userImage !== undefined) bucket['userImage'] = p.userImage
      if (p.phone !== undefined) bucket['phone'] = p.phone
      if (p.name !== undefined) bucket['name'] = p.name
      if (p.source !== undefined) bucket['source'] = p.source
      if (p.title !== undefined) bucket['title'] = p.title
      if (p.contentStr !== undefined) bucket['contentStr'] = p.contentStr
      if (p.likes !== undefined) bucket['likes'] = p.likes
      if (p.comments !== undefined) bucket['comments'] = p.comments
      if (p.shares !== undefined) bucket['shares'] = p.shares
    } else {
      if (a.UserImage !== undefined) bucket['userImage'] = a.UserImage
      if (a.Phone !== undefined) bucket['phone'] = a.Phone
      if (a.Name !== undefined) bucket['name'] = a.Name
      if (a.Source !== undefined) bucket['source'] = a.Source
      if (a.Title !== undefined) bucket['title'] = a.Title
      if (a.ContentStr !== undefined) bucket['contentStr'] = a.ContentStr
      if (a.Likes !== undefined) bucket['likes'] = a.Likes
      if (a.Comments !== undefined) bucket['comments'] = a.Comments
      if (a.Shares !== undefined) bucket['shares'] = a.Shares
    }
    return bucket
  }
  
  private getId(input: Article | ArticlePayload): number | undefined {
    const p = input as ArticlePayload
    if (p.id !== undefined) {
      return p.id
    }
    const a = input as Article
    return a.ID
  }

  public static getInstance(): ArticleData {
    if (!ArticleData.instance) {
      ArticleData.instance = new ArticleData()
    }
    return ArticleData.instance
  }

  public async initRdbStore(context: common.Context): Promise<void> {
    await IBestORMInit(context as common.UIAbilityContext, STORE_CONFIG_ARTICLE)
    GetIBestORM().AutoMigrate(Article)
    this.initialized = true
  }

  public async queryArticle(context: common.Context): Promise<Array<Article>> {
    await this.ensureInit(context)
    return GetIBestORM().Session(Article).OrderByAsc('id').Find(Article) as Array<Article>
  }

  public async queryPhoneArticle(context: common.Context, phone?: string): Promise<Array<Article>> {
    await this.ensureInit(context)
    let orm = GetIBestORM().Session(Article).OrderByAsc('id')
    if (phone) {
      orm = orm.Where('phone', phone)
    }
    return orm.Find(Article) as Array<Article>
  }

  public async queryLIkeArticle(context: common.Context, content: string): Promise<Array<Article>> {
    await this.ensureInit(context)
    return GetIBestORM().Session(Article).Like('title', `%${content}%`).OrderByAsc('id').Find(Article) as Array<Article>
  }

  public async addArticle(context: common.Context, article: Article | ArticlePayload): Promise<void> {
    await this.ensureInit(context)
    const values = this.toBucket(article)
    GetIBestORM().Table('article').Insert(values)
  }

  public async deleteArticle(context: common.Context, id: number): Promise<void> {
    await this.ensureInit(context)
    GetIBestORM().Table('article').Where('id', id).Delete()
  }

  public async updateArticle(context: common.Context, article: Article | ArticlePayload): Promise<void> {
    await this.ensureInit(context)
    const id = this.getId(article)
    if (id === undefined) {
      console.error(TAG, 'updateArticle 缺少主键 id')
      return
    }
    const values = this.toBucket(article)
    GetIBestORM().Table('article').Where('id', id).Update(values)
  }

  private async ensureInit(context: common.Context): Promise<void> {
    if (!this.initialized) {
      await this.initRdbStore(context)
    }
  }
}
