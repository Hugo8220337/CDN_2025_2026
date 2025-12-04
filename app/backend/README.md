Backend simples em TypeScript para gerir uma fila de bilhetes (ticketing).

Como funciona
- API HTTP para criar bilhetes e consultar o estado (`/tickets`, `/status/:id`, `/metrics`).
- Worker em memória que processa bilhetes de forma sequencial (simula um worker SQS).

Desenvolvimento
1. Instalar dependências:

```bash
cd app/backend
npm install
```

2. Executar em modo desenvolvimento (hot-reload):

```bash
npm run dev
```

3. Construir e correr:

```bash
npm run build
npm start
```

Notas
- Este backend usa uma fila em memória (não persistente). Para produção, ligue-o a SQS/DynamoDB.
- Se quiser, adiciono um `Dockerfile` para empacotar o serviço como container.
