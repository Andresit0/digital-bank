import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountsController } from './accounts.controller';
import { AccountsService } from './accounts.service';
import { Account } from './entities/account.entity';

@Module({
  controllers: [AccountsController],
  providers: [AccountsService],
  imports: [
    TypeOrmModule.forFeature([Account]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
})
export class AccountsModule {}
