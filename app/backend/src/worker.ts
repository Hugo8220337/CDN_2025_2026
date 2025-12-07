import Ticket from './models/ticket';

const INTERVAL_MS = 5000; // Processa 1 pessoa a cada 5 segundos

export function startWorker() {
  console.log('Worker iniciado: A processar a fila...');

  setInterval(async () => {
    try {
      //  Encontrar o bilhete mais antigo (FIFO) que ainda está 'WAITING'
      // .sort({ createdAt: 1 }) ordena do mais antigo para o mais recente
      const nextTicket = await Ticket.findOne({ status: 'WAITING' })
        .sort({ createdAt: 1 });

      if (nextTicket) {
        // Simular o processamento
        nextTicket.status = 'PROCESSED';
        await nextTicket.save();

        console.log(`Ticket processado: ${nextTicket._id} | Fila andou!`);
      } else {
        console.log('Fila vazia, worker à espera...');
      }

    } catch (error) {
      console.error('Erro no worker:', error);
    }
  }, INTERVAL_MS);
}