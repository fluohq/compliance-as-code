import express, { Request, Response, NextFunction } from 'express';
import { GDPR, ComplianceSpan } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

const app = express();
app.use(express.json());

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

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    version: '1.0.0',
    compliance: {
      frameworks: ['GDPR', 'SOC2'],
      controls: ['Art.15', 'Art.17', 'Art.5(1)(f)', 'CC6.1'],
    },
  });
});

// GET /user/:id - GDPR Art.15: Right of Access
app.get('/user/:id', (req: Request, res: Response) => {
  const span = GDPR.beginSpan(GDPR.Art_15);
  span.setInput('userId', req.params.id);
  span.setInput('operation', 'data_access');

  try {
    const user = usersDb.get(req.params.id);
    if (!user) {
      span.endWithError(new Error('User not found'));
      return res.status(404).json({ error: 'User not found' });
    }

    span.setOutput('email', user.email);
    span.setOutput('recordsReturned', 1);
    span.end();

    res.json(user);
  } catch (error) {
    span.endWithError(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /users - List all users
app.get('/users', (req: Request, res: Response) => {
  const span = GDPR.beginSpan(GDPR.Art_15);
  span.setInput('operation', 'list_all');

  try {
    const users = Array.from(usersDb.values());
    span.setOutput('recordsReturned', users.length);
    span.end();

    res.json(users);
  } catch (error) {
    span.endWithError(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /user - Create user
app.post('/user', (req: Request, res: Response) => {
  const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
  const soc2Span = SOC2.beginSpan(SOC2.CC6_1);

  try {
    const userId = `user_${Date.now()}`;
    const user: User = {
      id: userId,
      email: req.body.email,
      name: req.body.name,
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

    res.status(201).json(user);
  } catch (error) {
    gdprSpan.endWithError(error);
    soc2Span.endWithError(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /user/:id - GDPR Art.17: Right to Erasure
app.delete('/user/:id', (req: Request, res: Response) => {
  const span = GDPR.beginSpan(GDPR.Art_17);
  span.setInput('userId', req.params.id);
  span.setInput('operation', 'data_erasure');

  try {
    let deleted = 0;
    if (usersDb.has(req.params.id)) {
      usersDb.delete(req.params.id);
      deleted = 1;
    }

    span.setOutput('deletedRecords', deleted);
    span.setOutput('tablesCleared', 1);
    span.end();

    res.status(204).send();
  } catch (error) {
    span.endWithError(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log('='.repeat(50));
  console.log('Express Compliance Evidence Example');
  console.log('='.repeat(50));
  console.log();
  console.log('Frameworks: GDPR, SOC 2');
  console.log('Controls: Art.15, Art.17, Art.5(1)(f), CC6.1');
  console.log();
  console.log('Endpoints:');
  console.log('  GET    /health           - Health check');
  console.log('  GET    /user/:id         - Get user (GDPR Art.15)');
  console.log('  GET    /users            - List users');
  console.log('  POST   /user             - Create user (GDPR + SOC2)');
  console.log('  DELETE /user/:id         - Delete user (GDPR Art.17)');
  console.log();
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('='.repeat(50));
});
