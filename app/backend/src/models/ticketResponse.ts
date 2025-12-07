import * as AWS from 'aws-sdk';
import { docClient } from '../dynamo';

export class Ticket {
  id: string;
  bought: boolean;
  createdAt: string;

  constructor() {
    this.id = `ticket-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    this.bought = false;
    this.createdAt = new Date().toISOString();
  }
}

const TABLE_NAME = process.env.TABLE_NAME || 'QueueCounter';

const createTicket = async (ticket: Ticket) => {
  const params = {
    TableName: TABLE_NAME,
    Item: {
      id: ticket.id || '',
      bought: ticket.bought,
      createdAt: new Date().toISOString(),
    },
  }

  await docClient.put(params).promise();
}

export default createTicket;