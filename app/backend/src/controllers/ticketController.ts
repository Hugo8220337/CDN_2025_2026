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
        status: 'WAITING'
      });
      
      return res.status(201).json(newTicket);
    } catch (error) {
      return res.status(500).json({ error: 'Erro ao criar ticket' });
    }
  },

  // GET /tickets/:id/position
  async getPosition(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const myTicket = await Ticket.findOne({ _id: id });
      if (!myTicket) {
        return res.status(404).json({ error: 'Ticket não encontrado' });
      }

      // Contar quantos existem para o mesmo evento criados ANTES deste
      const peopleAhead = await Ticket.countDocuments({
        eventId: EVENT_ID,
        createdAt: { $lt: myTicket.createdAt }, // $lt = Less Than (Menor que)
        status: 'WAITING' // Opcional: só conta quem ainda está na fila
      });

      return res.json({
        _id: id,
        peopleAhead,
        currentPosition: peopleAhead + 1
      });

    } catch (error) {
      return res.status(500).json({ error: 'Erro ao calcular posição' });
    }
  }
};