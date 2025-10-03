import { Module } from '@nestjs/common';
import { UserController } from './user.controller';
import { HealthController } from './health.controller';

@Module({
  imports: [],
  controllers: [HealthController, UserController],
  providers: [],
})
export class AppModule {}
