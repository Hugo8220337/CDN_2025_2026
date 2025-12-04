import { Router } from 'express';
// import { incrementCounter, getCounter } from '../dynamo';

const router = Router();

// router.post('/request-ticket', async (req, res) => {
//   try {
//     const pos = await incrementCounter();
//     res.json({ message: `There are ${pos} people ahead of you in the queue.`, position: pos });
//   } catch (err) {
//     console.error('Error in /request-ticket', err);
//     res.status(500).json({ error: 'Error creating ticket' });
//   }
// });

// router.get('/queue-position', async (req, res) => {
//   try {
//     const pos = await getCounter();
//     res.json({ position: pos });
//   } catch (err) {
//     console.error('Error in /queue-position', err);
//     res.status(500).json({ error: 'Error reading position' });
//   }
// });

router.get('/health', (_req, res) => res.json({ status: 'ok', service: 'ticket-backend' }));

export default router;
