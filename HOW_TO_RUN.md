# Executar no AWS
Para poder colocar a aplicação disponível no AWS, primeiramente é necessário estar na pasta `infra/`, e depois executar os seguintes comandos:
```bash
tofu init
tofu plan
tofu apply
```

Quando acabar, é dado como outputs no terminal o URL para o website, e o url para a API.

Como não se colocou dados de testes diretamente na API quando a mesma liga, então para poder ver o comportamento de fila desejado no frontend, é aconselhado fazer vários pedidos no postman para `POST <<url>>/tickets`, ou abrir muitas abas e clicar no botão de comprar.

**IMPORTANTE:** Embora o site o site possa ser acedido por HTTPS, o mesmo deve ser acedido por HTTP para obter o comportamento esperado, visto que a API corre como HTTP, e caso se abra o site como HTTPS, dependendo do browser, irá barrar os pedidos da API.

# Executar Localmente
Para correr localemten basta correr o comando:
```bash
docker comppose up --build
```