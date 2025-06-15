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

## Executar testes

```bash
npm test
```

## Estrutura

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

## Arquitetura e Decisões Técnicas

- Separação de responsabilidades entre UI, lógica de negócio e estado
- Reutilização de código através de hooks customizados
- Experiência do usuário com feedback visual e validações
- Manutenibilidade com componentes pequenos

1. Custom Hooks para Abstração de Estado

- Reutilização
- Testabilidade
- Manutenibilidade
- Separação de responsabilidades

2. Componentes Pequenos e Focados

- Fácil debugging e manutenção
- Reutilização em diferentes contextos
- Testes mais simples

## Próximos Passos

- Paginação da listagem
- Aumentar a cobertura de testes
- Toasts para ações (sucesso, erro)
- Tela de detalhes por cliente
