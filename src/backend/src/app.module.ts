import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'path';

// Modules
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ProfileModule } from './profile/profile.module';
import { FamilyModule } from './family/family.module';
import { MemberModule } from './member/member.module';
import { InvitationModule } from './invitation/invitation.module';
import { NotificationModule } from './notification/notification.module';

@Module({
  imports: [
    // Configuration globale
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // GraphQL avec Apollo
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      sortSchema: true,
      playground: process.env.NODE_ENV !== 'production',
      introspection: process.env.NODE_ENV !== 'production',
      context: ({ req }) => ({ req }),
      formatError: (error) => {
        // Formater les erreurs pour le client
        const originalError = error.extensions?.originalError as any;
        
        return {
          message: error.message,
          code: error.extensions?.code || 'INTERNAL_ERROR',
          ...(originalError?.statusCode && { statusCode: originalError.statusCode }),
        };
      },
    }),

    // Modules métier
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
