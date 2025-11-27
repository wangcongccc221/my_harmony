/**
 * 数据库模块使用示例
 * 
 * 这个文件展示了如何在其他项目中使用数据库模块
 * 可以直接复制这些代码到你的项目中
 */

import { Context } from '@kit.AbilityKit';
import { DatabaseHelper } from './index';

// ==================== 示例 1: 基本 CRUD 操作 ====================

/**
 * 用户服务示例
 */
export class UserService {
  /**
   * 查询所有用户
   */
  static async getAllUsers(ctx: Context) {
    return await DatabaseHelper.queryAll(ctx, 'users');
  }

  /**
   * 分页查询用户
   */
  static async getUsersByPage(ctx: Context, page: number, size: number) {
    return await DatabaseHelper.queryPage(ctx, 'users', page, size);
  }

  /**
   * 添加用户
   */
  static async addUser(ctx: Context, name: string, email: string): Promise<number> {
    const id = await DatabaseHelper.insert(ctx, 'users', {
      name: name,
      email: email,
      created_at: new Date().toISOString()
    });
    return id;
  }

  /**
   * 更新用户
   */
  static async updateUser(ctx: Context, id: number, name: string): Promise<number> {
    const affected = await DatabaseHelper.update(ctx, 'users', id, {
      name: name,
      updated_at: new Date().toISOString()
    });
    return affected;
  }

  /**
   * 删除用户
   */
  static async deleteUser(ctx: Context, id: number): Promise<number> {
    const deleted = await DatabaseHelper.delete(ctx, 'users', id);
    return deleted;
  }

  /**
   * 统计用户数
   */
  static async getUserCount(ctx: Context): Promise<number> {
    return await DatabaseHelper.count(ctx, 'users');
  }
}

// ==================== 示例 2: 批量操作 ====================

/**
 * 批量导入数据
 */
export async function batchImportUsers(ctx: Context, users: Array<Record<string, any>>): Promise<number> {
  const valuesList = users.map(user => ({
    name: user.name,
    email: user.email,
    created_at: new Date().toISOString()
  }));
  
  return await DatabaseHelper.batchInsert(ctx, 'users', valuesList);
}

// ==================== 示例 3: 使用原生 SQL ====================

/**
 * 复杂查询示例
 */
export async function getUsersByCondition(ctx: Context, minAge: number): Promise<Array<Record<string, any>>> {
  const sql = `SELECT * FROM users WHERE age >= ${minAge} ORDER BY created_at DESC`;
  return await DatabaseHelper.querySql(ctx, sql);
}

// ==================== 示例 4: 在组件中使用 ====================

/**
 * 在 @Component 中使用数据库
 */
// @Component
export struct UserListComponent {
  @State users: Array<Record<string, any>> = [];

  async loadUsers(ctx: Context) {
    this.users = await DatabaseHelper.queryAll(ctx, 'users');
  }

  build() {
    // UI 代码
  }
}

// ==================== 示例 5: 在 HTTP Handler 中使用 ====================

/**
 * HTTP API Handler 示例
 */
export async function handleGetUsers(ctx: Context): Promise<string> {
  const users = await DatabaseHelper.queryAll(ctx, 'users');
  return JSON.stringify({ ok: true, data: users });
}

export async function handleCreateUser(ctx: Context, body: string): Promise<string> {
  const userData = JSON.parse(body);
  const id = await DatabaseHelper.insert(ctx, 'users', {
    name: userData.name,
    email: userData.email,
    created_at: new Date().toISOString()
  });
  return JSON.stringify({ ok: true, id: id });
}

// ==================== 示例 6: 使用类型定义 ====================

/**
 * 定义数据类型
 */
interface User {
  id?: number;
  name: string;
  email: string;
  created_at?: string;
}

/**
 * 类型安全的查询
 */
export async function getUsersTyped(ctx: Context): Promise<User[]> {
  return await DatabaseHelper.queryAll<User>(ctx, 'users');
}

// ==================== 示例 7: 错误处理 ====================

/**
 * 带错误处理的数据库操作
 */
export async function safeGetUsers(ctx: Context): Promise<User[] | null> {
  try {
    return await DatabaseHelper.queryAll<User>(ctx, 'users');
  } catch (error) {
    console.error('查询用户失败:', error);
    return null;
  }
}

