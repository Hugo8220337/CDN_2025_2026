import { Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import Ticket from '../models/ticket';

// Hardcoded para simplificar, num cenário real viria do body
const EVENT_ID = "concerto-coldplay";

export const ticketController = {
  
  // POST /tickets
  async create(req: Request, res: Response) {
    try {
      const newTicket = await Ticket.create({
        eventId: EVENT_ID,
        status: 'WAITING',
      });
      res.status(201).json(newTicket);
    } catch(error: any) {
      res.status(500).json({ error: 'Error creating ticket: ' + error.message });
    }
  },

  // GET /tickets/:id/position
  async getPosition(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const myTicket = await Ticket.findById(id);
      if (!myTicket) {
        return res.status(404).json({ error: 'Ticket not found' });
      }

      const peopleAhead = await Ticket.countDocuments({
        eventId: EVENT_ID,
        createdAt: { $lt: myTicket.createdAt },
        status: 'WAITING',
      });

      res.json({
        _id: id,
        peopleAhead,
        currentPosition: peopleAhead + 1,
      });
    } catch (error: any) {
      res.status(500).json({ error: 'Error calculating position: ' + error.message });
    }
  }
};