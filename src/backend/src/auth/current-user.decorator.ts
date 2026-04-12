import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';

/**
 * Décorateur pour injecter le profil utilisateur courant dans les resolvers
 * 
 * @example
 * @Query(() => Profile)
 * @UseGuards(JwtAuthGuard)
 * async me(@CurrentUser() user: Profile) {
 *   return user;
 * }
 */
export const CurrentUser = createParamDecorator(
  (data: unknown, context: ExecutionContext) => {
    const ctx = GqlExecutionContext.create(context);
    return ctx.getContext().req.user;
  },
);
