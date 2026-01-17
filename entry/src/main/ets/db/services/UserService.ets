import { getORM, validate } from '@ibestservices/ibest-orm';
import { User } from '../entities/User';

export class UserService {
  private static instance: UserService;

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  /**
   * Create a single user
   */
  public async createUser(name: string, age: number): Promise<number | undefined> {
    const orm = getORM();
    const user = new User();
    user.name = name;
    user.age = age;

    const result = validate(user);
    if (!result.valid) {
      console.error('【database】: Validation failed:', JSON.stringify(result.errors));
      return undefined;
    }

    const id = await orm.insert(user);
    console.info(`【database】: User created with ID: ${id}`);
    return id as number;
  }

  /**
   * Batch create users
   */
  public async createUsersBatch(usersData: Array<{ name: string, age: number }>): Promise<void> {
    const orm = getORM();
    
    for (const data of usersData) {
      const user = new User();
      user.name = data.name;
      user.age = data.age;
      await orm.insert(user);
    }
    console.info(`【database】: Batch created ${usersData.length} users`);
  }

  /**
   * Save or update user (Smart Save)
   */
  public async saveOrUpdateUser(user: User): Promise<void> {
    const orm = getORM();
    await orm.save(user);
    console.info(`【database】: User saved: ${user.name}`);
  }

  /**
   * Create users in transaction
   */
  public async createUsersInTransaction(): Promise<void> {
    const orm = getORM();
    
    try {
      await orm.transaction(async () => {
        const user1 = new User();
        user1.name = 'Transaction User 1';
        user1.age = 20;
        await orm.insert(user1);

        const user2 = new User();
        user2.name = 'Transaction User 2';
        user2.age = 22;
        await orm.insert(user2);
        
        console.info('【database】: Transaction committed successfully');
      });
    } catch (error) {
      console.error('【database】: Transaction failed, rolled back:', error);
    }
  }
}