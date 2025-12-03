// Simulação de dados dinâmicos - substituir por chamadas API reais
function updateQueueData() {
  // Posição na fila (simulação)
  const currentPosition = parseInt(
    document.getElementById("position").textContent
  );
  const newPosition = Math.max(
    1,
    currentPosition - Math.floor(Math.random() * 3)
  );
  document.getElementById("position").textContent = newPosition;

  // Atualizar progresso
  const progress = Math.min(
    100,
    Math.max(0, ((250 - newPosition) / 250) * 100)
  );
  document.getElementById("progressBar").style.width = progress + "%";
  document.getElementById("completionRate").textContent =
    Math.round(progress) + "%";
  document.getElementById("processedUsers").textContent = 250 - newPosition;

  // Atualizar mensagem de status
  const messages = [
    "⏳ Aproximadamente 2 minutos de espera",
    "🚀 Processando rapidamente...",
    "📈 Sua posição está melhorando!",
    "🎯 Quase lá! Prepare-se",
  ];
  document.getElementById("statusMessage").textContent =
    messages[Math.floor(Math.random() * messages.length)];

  // Atualizar métricas do sistema (simulação)
  document.getElementById("responseTime").textContent =
    (Math.random() * 100 + 50).toFixed(0) + "ms";
  document.getElementById("cpuUsage").textContent =
    (Math.random() * 50 + 20).toFixed(0) + "%";
  document.getElementById("queueMessages").textContent = Math.floor(
    Math.random() * 100
  );
  document.getElementById("requestsPerMinute").textContent = Math.floor(
    Math.random() * 1000 + 800
  ).toLocaleString();
  document.getElementById("activeTasks").textContent = Math.floor(
    Math.random() * 3 + 1
  );

  // Atualizar timestamp
  const now = new Date();
  document.getElementById("updateTime").textContent = now.toLocaleTimeString();
  document.getElementById("lastUpdate").textContent = now.toLocaleTimeString();
  document.getElementById("nextUpdate").textContent = "10s";
}
