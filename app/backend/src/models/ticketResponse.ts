import * as AWS from 'aws-sdk';

const dynamoDB = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.TABLE_NAME || 'QueueCounter';


interface Ticket {
  ticketId: string;
  message: string;
  position: number;
}

const createTicket = async (ticket: Ticket) => {
  const params = {
    TableName: TABLE_NAME,
    Item: {
      ticketId: ticket.ticketId || '',
      message: ticket.message,
      position: ticket.position,
    },
  }

  await dynamoDB.put(params).promise();
}

export default createTicket;