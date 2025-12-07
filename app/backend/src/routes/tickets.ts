import { Router } from 'express';
import createTicket, { Ticket } from '../models/ticketResponse';

const router = Router();

router.post('/request-ticket', async (_, res) => {
  try {
    const ticketToCreate = new Ticket();
    const ticket = await createTicket(ticketToCreate);
    res.json(ticket);
  } catch (err) {
    console.error('Error in /request-ticket', err);
    res.status(500).json({ error: 'Error creating ticket' + err });
  }
});

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
