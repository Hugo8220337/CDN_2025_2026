import express from 'express';
import cors from 'cors';
import ticketRoutes from './routes/ticketRoutes';

const app = express();

app.use(cors());
app.use(express.json());

app.use('/tickets', ticketRoutes);

app.get('/health', (req, res) => {
  res.send('Está a funcionar!');
});

export default app;