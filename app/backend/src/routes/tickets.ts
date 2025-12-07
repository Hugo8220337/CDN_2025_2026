import { Router } from 'express';
import { ticketController } from '../controllers/ticketController';

const router = Router();

router.post('/', ticketController.create);
router.get('/:id/position', ticketController.getPosition);

export default router;