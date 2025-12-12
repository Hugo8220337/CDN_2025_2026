# Executar no AWS
Para poder colocar a aplicação disponível no AWS, primeiramente é necessário estar na pasta `infra/`, e depois executar os seguintes comandos:
```bash
tofu plan
tofu apply
```

# Executar Localmente
Para correr localemten basta correr o comando:
```bash
docker comppose up --build
```