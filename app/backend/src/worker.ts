// import { getCounter, decrementCounter } from './dynamo';

// let running = false;

// export function startWorker(intervalMs = 10000) {
//   if (running) return;
//   running = true;
//   console.log('[Worker] Starting worker loop');
//   (async function loop() {
//     while (running) {
//       try {
//         const current = await getCounter();
//         if (current > 0) {
//           const newVal = await decrementCounter();
//           console.log(`[Worker] Processed 1 ticket. Remaining: ${newVal}`);
//         }
//       } catch (err) {
//         console.error('[Worker] Erro:', err);
//       }
//       await new Promise((r) => setTimeout(r, intervalMs));
//     }
//   })();
// }

// export function stopWorker() {
//   running = false;
// }
