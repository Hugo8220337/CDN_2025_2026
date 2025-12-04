// async function createTicket() {
//   const response = await fetch("http://localhost:3000/tickets", {
//     method: "POST",
//   });
//   const data = await response.json();

//   document.getElementById("position").innerText = `Ticket ID: ${data.id}, Position in Queue: ${data.position}`;
//   document.getElementById("requestTicketBtn").disabled = true;
// }

const API_URL = process.env.API_URL || 'http://backend:3000';

async function createTicket() {
  try {
    const btn = document.getElementById('requestTicketBtn');
    btn.disabled = true;
    btn.textContent = 'A processar...';
    
    const response = await fetch(`${API_URL}/request-ticket`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    document.getElementById('position').innerText = 
      `${data.position} pessoas na sua frente`;
    
    // Atualiza a posição a cada 5 segundos
    const intervalId = setInterval(async () => {
      const posResponse = await fetch(`${API_URL}/queue-position`);
      const posData = await posResponse.json();
      
      document.getElementById('position').innerText = 
        `${posData.position} pessoas na sua frente`;
      
      if (posData.position === 0) {
        clearInterval(intervalId);
        btn.disabled = false;
        btn.textContent = 'Pedir Bilhete';
        document.getElementById('position').innerText = 'É a sua vez!';
      }
    }, 5000);
    
  } catch (error) {
    console.error('Erro:', error);
    document.getElementById('position').innerText = 'Erro ao pedir bilhete';
    document.getElementById('requestTicketBtn').disabled = false;
    document.getElementById('requestTicketBtn').textContent = 'Pedir Bilhete';
  }
}