import { API_URL } from "./config.js";

/**
 * Faz polling para atualizar a posição do ticket
 */
async function _startPositionUpdater(ticketId, btn) {
  const intervalId = setInterval(async () => {
    try {
      const posResponse = await fetch(`${API_URL}/tickets/${ticketId}/position`);
      const posData = await posResponse.json();

      // document.getElementById("position").innerText = `${posData.currentPosition - 1} pessoas à frente`;
      document.getElementById("position").innerText = `${posData.currentPosition} pessoas à frente`;

      if (posData.currentPosition === 1) {
        clearInterval(intervalId);
        btn.disabled = false;
        btn.textContent = "Pedir Bilhete";
        document.getElementById("position").innerText = "A sua vez!";
      }
    } catch (err) {
      console.error("Erro polling:", err);
    }
  }, 3000);
}

/**
 * Pede um novo ticket à API
 */
async function requestTicket() {
  try {
    // debugger;
    const btn = document.getElementById("requestTicketBtn");
    btn.disabled = true;
    btn.textContent = "A processar...";

    const response = await fetch(`${API_URL}/tickets`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    });

    const data = await response.json();

    // Atualiza a posição a cada 5 segundos
    // Chama a função que faz o polling
    _startPositionUpdater(data._id, btn);
  } catch (error) {
    console.error("Erro:", error);
    document.getElementById("error").innerText = error.message;
    document.getElementById("position").innerText = "Erro ao pedir bilhete";
    document.getElementById("requestTicketBtn").disabled = false;
    document.getElementById("requestTicketBtn").textContent = "Pedir Bilhete";
  }
}


// Adiciona o event listener ao botão de pedir bilhete
document.getElementById("requestTicketBtn").addEventListener("click", requestTicket);