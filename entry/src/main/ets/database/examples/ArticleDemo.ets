import { common } from '@kit.AbilityKit'
import { Article } from '../models/Article'
import { taskPoolExecuteInsert, taskPoolExecuteQuery } from './taskpool'

@Entry
@Component
struct ArticleDemo {
  @State articleList: Article[] = []
  @State titleInput: string = ''
  @State contentInput: string = ''

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.Context
    const articles = await taskPoolExecuteQuery(context)
    this.articleList = articles
  }

  build() {
    Column() {
      TextInput({ placeholder: '输入文章标题' })
        .onChange((value: string) => {
          this.titleInput = value
        })

      TextInput({ placeholder: '输入文章内容' })
        .onChange((value: string) => {
          this.contentInput = value
        })

      Button('添加文章')
        .onClick(async () => {
          if (this.titleInput === '' || this.contentInput === '') {
            console.warn('ArticleRdb', '标题或内容为空，不添加文章')
            return
          }

          const context = getContext(this) as common.Context
          const newArticle = new Article(
            undefined,
            'default_image_url',
            '1234567890',
            '默认用户',
            '默认来源',
            this.titleInput,
            this.contentInput,
            0,
            0,
            0
          )

          await taskPoolExecuteInsert(context, newArticle)
          const updated = await taskPoolExecuteQuery(context)
          this.articleList = updated
          this.titleInput = ''
          this.contentInput = ''
        })

      List({ space: 8 }) {
        ForEach(this.articleList, (article: Article) => {
          ListItem() {
            Column() {
              Text(`标题: ${article.Title ?? ''}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
              Text(`内容: ${article.ContentStr ?? ''}`)
                .fontSize(16)
              Text(`点赞: ${article.Likes ?? 0} | 评论: ${article.Comments ?? 0} | 收藏: ${article.Shares ?? 0}`)
                .fontSize(14)
                .fontColor('#666')
            }
            .width('100%')
            .padding(10)
            .borderRadius(8)
            .backgroundColor('#f5f5f5')
          }
        }, (article: Article) => article.ID?.toString() ?? '')
      }
      .width('100%')
    }
    .padding(10)
  }
}
