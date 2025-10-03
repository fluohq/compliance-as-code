import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  HttpCode,
  HttpStatus,
  NotFoundException,
} from '@nestjs/common';
import { GDPR, ComplianceSpan } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

interface User {
  id: string;
  email: string;
  name: string;
}

// In-memory user store for demo
const usersDb: Map<string, User> = new Map([
  ['123', { id: '123', email: 'alice@example.com', name: 'Alice' }],
  ['456', { id: '456', email: 'bob@example.com', name: 'Bob' }],
]);

@Controller('user')
export class UserController {
  @Get(':id')
  async getUser(@Param('id') userId: string): Promise<User> {
    // GDPR Art.15: Right of Access
    const span = GDPR.beginSpan(GDPR.Art_15);
    span.setInput('userId', userId);
    span.setInput('operation', 'data_access');

    try {
      const user = usersDb.get(userId);
      if (!user) {
        span.endWithError(new Error('User not found'));
        throw new NotFoundException('User not found');
      }

      span.setOutput('email', user.email);
      span.setOutput('recordsReturned', 1);
      span.end();

      return user;
    } catch (error) {
      span.endWithError(error);
      throw error;
    }
  }

  @Get()
  async listUsers(): Promise<User[]> {
    // GDPR Art.15: Right of Access
    const span = GDPR.beginSpan(GDPR.Art_15);
    span.setInput('operation', 'list_all');

    try {
      const users = Array.from(usersDb.values());
      span.setOutput('recordsReturned', users.length);
      span.end();

      return users;
    } catch (error) {
      span.endWithError(error);
      throw error;
    }
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createUser(@Body() createUserDto: Omit<User, 'id'>): Promise<User> {
    // Multi-framework evidence: GDPR Art.5(1)(f) + SOC 2 CC6.1
    const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
    const soc2Span = SOC2.beginSpan(SOC2.CC6_1);

    try {
      // Generate user ID
      const userId = `user_${Date.now()}`;
      const user: User = {
        id: userId,
        ...createUserDto,
      };

      gdprSpan.setInput('email', user.email);
      gdprSpan.setInput('operation', 'create_user');

      soc2Span.setInput('userId', userId);
      soc2Span.setInput('action', 'create_user');
      soc2Span.setInput('authorized', true);

      // Store user
      usersDb.set(userId, user);

      gdprSpan.setOutput('userId', userId);
      gdprSpan.setOutput('recordsCreated', 1);
      gdprSpan.end();

      soc2Span.setOutput('result', 'success');
      soc2Span.end();

      return user;
    } catch (error) {
      gdprSpan.endWithError(error);
      soc2Span.endWithError(error);
      throw error;
    }
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteUser(@Param('id') userId: string): Promise<void> {
    // GDPR Art.17: Right to Erasure
    const span = GDPR.beginSpan(GDPR.Art_17);
    span.setInput('userId', userId);
    span.setInput('operation', 'data_erasure');

    try {
      let deleted = 0;
      if (usersDb.has(userId)) {
        usersDb.delete(userId);
        deleted = 1;
      }

      span.setOutput('deletedRecords', deleted);
      span.setOutput('tablesCleared', 1);
      span.end();
    } catch (error) {
      span.endWithError(error);
      throw error;
    }
  }
}
