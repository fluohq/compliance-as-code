import { initTRPC } from '@trpc/server';
import { createHTTPServer } from '@trpc/server/adapters/standalone';
import { z } from 'zod';
import { GDPR } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

// Initialize tRPC
const t = initTRPC.create();

// In-memory user store
interface User {
  id: string;
  email: string;
  name: string;
}

const usersDb = new Map<string, User>([
  ['123', { id: '123', email: 'alice@example.com', name: 'Alice' }],
  ['456', { id: '456', email: 'bob@example.com', name: 'Bob' }],
]);

// Define router
export const appRouter = t.router({
  health: t.procedure.query(() => ({
    status: 'healthy',
    version: '1.0.0',
    compliance: {
      frameworks: ['GDPR', 'SOC2'],
      controls: ['Art.15', 'Art.17', 'Art.5(1)(f)', 'CC6.1'],
    },
  })),

  // GET user - GDPR Art.15
  getUser: t.procedure
    .input(z.object({ id: z.string() }))
    .query(({ input }) => {
      const span = GDPR.beginSpan(GDPR.Art_15);
      span.setInput('userId', input.id);
      span.setInput('operation', 'data_access');

      try {
        const user = usersDb.get(input.id);
        if (!user) {
          span.endWithError(new Error('User not found'));
          throw new Error('User not found');
        }

        span.setOutput('email', user.email);
        span.setOutput('recordsReturned', 1);
        span.end();

        return user;
      } catch (error) {
        span.endWithError(error);
        throw error;
      }
    }),

  // List users - GDPR Art.15
  listUsers: t.procedure.query(() => {
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
  }),

  // Create user - GDPR Art.5(1)(f) + SOC 2 CC6.1
  createUser: t.procedure
    .input(
      z.object({
        email: z.string().email(),
        name: z.string(),
      })
    )
    .mutation(({ input }) => {
      const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
      const soc2Span = SOC2.beginSpan(SOC2.CC6_1);

      try {
        const userId = `user_${Date.now()}`;
        const user: User = {
          id: userId,
          ...input,
        };

        gdprSpan.setInput('email', user.email);
        gdprSpan.setInput('operation', 'create_user');

        soc2Span.setInput('userId', userId);
        soc2Span.setInput('action', 'create_user');
        soc2Span.setInput('authorized', true);

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
    }),

  // Delete user - GDPR Art.17
  deleteUser: t.procedure
    .input(z.object({ id: z.string() }))
    .mutation(({ input }) => {
      const span = GDPR.beginSpan(GDPR.Art_17);
      span.setInput('userId', input.id);
      span.setInput('operation', 'data_erasure');

      try {
        let deleted = 0;
        if (usersDb.has(input.id)) {
          usersDb.delete(input.id);
          deleted = 1;
        }

        span.setOutput('deletedRecords', deleted);
        span.setOutput('tablesCleared', 1);
        span.end();

        return { deleted };
      } catch (error) {
        span.endWithError(error);
        throw error;
      }
    }),
});

export type AppRouter = typeof appRouter;

// Create HTTP server
const server = createHTTPServer({
  router: appRouter,
});

server.listen(3000);

console.log('='.repeat(50));
console.log('tRPC Compliance Evidence Example');
console.log('='.repeat(50));
console.log();
console.log('Frameworks: GDPR, SOC 2');
console.log('Controls: Art.15, Art.17, Art.5(1)(f), CC6.1');
console.log();
console.log('Procedures:');
console.log('  health           - Health check');
console.log('  getUser          - Get user (GDPR Art.15)');
console.log('  listUsers        - List users');
console.log('  createUser       - Create user (GDPR + SOC2)');
console.log('  deleteUser       - Delete user (GDPR Art.17)');
console.log();
console.log('Server running on http://localhost:3000');
console.log('Type-safe RPC with compliance evidence');
console.log('='.repeat(50));
