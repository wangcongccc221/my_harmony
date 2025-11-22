import { Table, Field, FieldType, Model } from '../orm'

@Table({ name: 'article' })
export class Article extends Model {
  @Field({ name: 'userImage', type: FieldType.TEXT, tag: ['notNull'] })
  UserImage?: string
  @Field({ name: 'phone', type: FieldType.TEXT, tag: ['notNull'] })
  Phone?: string
  @Field({ name: 'name', type: FieldType.TEXT, tag: ['notNull'] })
  Name?: string
  @Field({ name: 'source', type: FieldType.TEXT, tag: ['notNull'] })
  Source?: string
  @Field({ name: 'title', type: FieldType.TEXT, tag: ['notNull'] })
  Title?: string
  @Field({ name: 'contentStr', type: FieldType.TEXT, tag: ['notNull'] })
  ContentStr?: string
  @Field({ name: 'likes', type: FieldType.INTEGER, tag: ['notNull'] })
  Likes?: number
  @Field({ name: 'comments', type: FieldType.INTEGER, tag: ['notNull'] })
  Comments?: number
  @Field({ name: 'shares', type: FieldType.INTEGER, tag: ['notNull'] })
  Shares?: number

  constructor(id?: number, userImage?: string, phone?: string, name?: string, source?: string, title?: string, contentStr?: string, likes?: number, comments?: number, shares?: number) {
    super()
    this.ID = id
    this.UserImage = userImage
    this.Phone = phone
    this.Name = name
    this.Source = source
    this.Title = title
    this.ContentStr = contentStr
    this.Likes = likes
    this.Comments = comments
    this.Shares = shares
  }
}

export interface ArticlePayload {
  id?: number
  userImage: string
  phone: string
  name: string
  source: string
  title: string
  contentStr: string
  likes: number
  comments: number
  shares: number
}

export const TAG = 'ArticleRdb'
