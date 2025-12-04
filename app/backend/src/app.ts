import express from 'express';
import cors from 'cors';
import ticketsRouter from './routes/tickets';

const app = express();
app.use(cors());
app.use(express.json());

app.use('/', ticketsRouter);

export default app;
