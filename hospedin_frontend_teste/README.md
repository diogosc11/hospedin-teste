Interface web desenvolvida para simular a centralização de cobranças de produtos da Hospedin (PMS, Motor, Channel), com controle visual e filtro de pagamentos, utilizando o Pagar.me como gateway (simulado).

## Funcionalidades

- Listagem de pagamentos em tabela
- Filtros por produto, status e tipo de cobrança
- Criação de novo pagamento via modal
- Carregamento dinâmico de clientes e produtos

## Tecnologias Utilizadas

- React
- React Bootstrap
- Vite

## Como rodar localmente

```bash
git clone https://github.com/diogosc11/hospedin-teste.git
cd hospedin_frontend_teste

npm install
npm run dev
```

> O backend deve estar rodando em `http://localhost:3000`

## Estrutura Principal

```
src/
├── App.js
├── hooks/
│   ├── usePayments.js
│   ├── useClients.js
│   └── useProducts.js
├── components/
│   ├── CustomTable/
│   └── NewPayment/
```

## Próximos Passos

- Paginação da listagem
- Criação de testes unitários, de integração e E2E
- Toasts para ações (sucesso, erro)
- Tela de detalhes por cliente
