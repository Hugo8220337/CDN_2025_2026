import { API_URL } from "./config.js";

const TIME_POLLING = 5000; // em ms
const ui = {
  button: document.getElementById("requestTicketBtn"),
  positionDisplay: document.getElementById("position"),
};

/**
 * Faz polling para atualizar a posição do ticket
 */
async function _startPositionUpdater(ticketId, btn) {
  const intervalId = setInterval(async () => {
    try {
      const posResponse = await fetch(
        `${API_URL}/tickets/${ticketId}/position`
      );
      const posData = await posResponse.json();

      ui.positionDisplay.innerText = `${
        posData.currentPosition - 1
      } pessoas à frente`;

      // se a posição for 1, é a vez do utilizador
      if (posData.currentPosition === 1) {
        clearInterval(intervalId); // Para de verificar
        ui.positionDisplay.innerText = "Comprado!";

        // Reativar o botão
        ui.button.disabled = false;
        ui.button.textContent = "Comprar Agora";
      }
    } catch (err) {
      console.error("Erro polling:", err);
    }
  }, TIME_POLLING); // a cada 5 segundos
}

/**
 * Pede um novo ticket à API
 */
async function requestTicket() {
  try {
    // Bloqueiar o botão e avisa que está a carregar
    ui.button.disabled = true;
    ui.button.textContent = "A processar...";
    ui.positionDisplay.innerText = "-";

    // Pedido à API para cirar um novo ticket
    const response = await fetch(`${API_URL}/tickets`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
    });

    const ticket = await response.json();

    // Atualizar UI
    ui.button.textContent = "Na Fila (A aguardar...)";

    // Inicia a monitorização da posição (loop de polling)
    _startPositionUpdater(ticket._id);
  } catch (error) {
    console.error(error);
    ui.positionDisplay.innerText = "Erro";
    ui.errorDisplay.innerText = "Não foi possível conectar ao sistema.";

    // Devolve o botão ao estado normal
    ui.button.disabled = false;
    ui.button.textContent = "Tentar Novamente";
  }
}

// Adiciona o event listener ao botão de pedir bilhete
document
  .getElementById("requestTicketBtn")
  .addEventListener("click", requestTicket);
