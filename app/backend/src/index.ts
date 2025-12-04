import app from "./app";
import { ensureTable } from "./dynamo";
// import { startWorker } from "./worker";

const PORT = process.env.PORT || 3000;

(async function main() {
  try {
    // Ensure DynamoDB table exists
    await ensureTable();

    // Start Express server
    app.listen(PORT, () => console.log(`🚀 Backend running on port ${PORT}`));

    // Start worker loop
    // startWorker(Number(process.env.WORKER_INTERVAL_MS) || 10000);
  } catch (err) {
    console.error("Fatal error during startup:", err);
    process.exit(1);
  }
})();
