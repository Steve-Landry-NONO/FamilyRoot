import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'path';

import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ProfileModule } from './profile/profile.module';
import { FamilyModule } from './family/family.module';
import { MemberModule } from './member/member.module';
import { InvitationModule } from './invitation/invitation.module';
import { NotificationModule } from './notification/notification.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      sortSchema: true,
      playground: process.env.NODE_ENV !== 'production',
      introspection: process.env.NODE_ENV !== 'production',
      context: ({ req }) => ({ req }),
      // Désactiver la protection CSRF en dev (Flutter Web ne peut pas envoyer ces headers)
      csrfPrevention: false,
      formatError: (error) => {
        const originalError = error.extensions?.originalError as any;
        return {
          message: error.message,
          code: error.extensions?.code || 'INTERNAL_ERROR',
          ...(originalError?.statusCode && { statusCode: originalError.statusCode }),
        };
      },
    }),

    PrismaModule,
    AuthModule,
    ProfileModule,
    FamilyModule,
    MemberModule,
    InvitationModule,
    NotificationModule,
  ],
})
export class AppModule {}
