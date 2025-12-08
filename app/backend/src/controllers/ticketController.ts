import { Request, Response } from "express";
import Ticket from "../models/ticket";
import os from 'os';


// Hardcoded para simplificar, num cenário real viria do body
const EVENT_ID = "concerto-coldplay";

export const ticketController = {
  // POST /tickets
  async create(req: Request, res: Response) {
    try {
      const newTicket = await Ticket.create({
        eventId: EVENT_ID,
        status: "WAITING",
      });
      res.status(201).json(newTicket);
    } catch (error: any) {
      res
        .status(500)
        .json({ error: "Error creating ticket: " + error.message });
    }
  },

  // GET /tickets/:id/position
  async getPosition(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const myTicket = await Ticket.findById(id);
      if (!myTicket) {
        return res.status(404).json({ error: "Ticket not found" });
      }

      const peopleAhead = await Ticket.countDocuments({
        eventId: EVENT_ID,
        createdAt: { $lt: myTicket.createdAt },
        status: "WAITING",
      });

      // Obter IP do servidor para o professor ver que existe mais que uma instância
      const serverIp = os.networkInterfaces();
      const ipAddresses = Object.values(serverIp)
        .flat()
        .filter((iface) => iface?.family === "IPv4" && !iface.internal)
        .map((iface) => iface?.address);

      res.json({
        _id: id,
        peopleAhead,
        currentPosition: peopleAhead + 1,
        serverIp: ipAddresses[0] || "IP not found",
      });
    } catch (error: any) {
      res
        .status(500)
        .json({ error: "Error calculating position: " + error.message });
    }
  },
};
