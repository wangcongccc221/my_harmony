import { Table, Column, PrimaryKey, CreatedAt, UpdatedAt } from '@ibestservices/ibest-orm';

@Table()
export class User {
  @PrimaryKey()
  id?: number;

  @Column()
  name?: string;

  @Column()
  age?: number;

  @CreatedAt()
  createdAt?: string;

  @UpdatedAt()
  updatedAt?: string;
}