import app from './app';
import { connectDB } from './config/db';
import { startWorker } from './worker';

const PORT = process.env.PORT || 3000;

(async () => {
  await connectDB();

  startWorker();
  
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
})();