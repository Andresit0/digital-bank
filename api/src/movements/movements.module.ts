import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Account } from '../accounts/entities/account.entity';
import { Movement } from './entities/movement.entity';
import { MovementsController } from './movements.controller';
import { MovementsService } from './movements.service';

@Module({
  controllers: [MovementsController],
  providers: [MovementsService],
  imports: [
    TypeOrmModule.forFeature([Movement, Account]),
    PassportModule.register({ defaultStrategy: 'jwt' }),
  ],
})
export class MovementsModule {}
