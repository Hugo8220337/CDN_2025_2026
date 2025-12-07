import express from 'express';
import cors from 'cors';
import ticketRoutes from './services/ticketRoutes';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/tickets', ticketRoutes);

export default app;