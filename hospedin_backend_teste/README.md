API RESTful simulando a unificação da cobrança dos produtos da Hospedin, utilizando o gateway Pagar.me (mock). Permite registrar, processar e consultar pagamentos, incluindo tratamento de webhooks e múltiplos produtos por cliente.

## Funcionalidades

- Cadastro de clientes, produtos e pagamentos
- Criação de múltiplos pagamentos em lote
- Simulação de sucesso/falha no Pagar.me com delay
- Webhooks automáticos com diferentes eventos
- Validações completas de CPF/CNPJ/documentos

## Tecnologias Utilizadas

- Ruby on Rails 7+
- SQLite

## Como rodar localmente

```bash
git clone https://github.com/diogosc11/hospedin-teste.git
cd hospedin-backend-teste

bundle install
rails db:migrate
rails db:seed
rails server -p 3000
```

A API estará disponível em `http://localhost:3000/api/v1`.

## Endpoints

| Método | Endpoint                        | Função                                  |
|--------|----------------------------------|------------------------------------------|
| GET    | `/api/v1/payments`              | Listar pagamentos com filtros            |
| POST   | `/api/v1/payments`              | Criar pagamentos para cliente/produto(s) |
| GET    | `/api/v1/clients`               | Listar clientes                          |
| POST   | `/api/v1/clients`               | Criar novo cliente                       |
| GET    | `/api/v1/products`              | Listar produtos                          |
| POST   | `/api/v1/webhooks/pagarme`      | Receber eventos simulados do gateway     |

## Estrutura

```
app/
├── controllers/api/v1/
├── jobs/
├── models/
└── services/ (em potencial)
```

## Próximos Passos

- Dashboard de faturamento e histórico de webhooks
- Implementação de testes com RSpec
- Integração real com Pagar.me

## Diferenciais

- Webhook completo com múltiplos tipos de eventos
- Processamento assíncrono com simulação de delay
- Multi-produtos por cliente no mesmo fluxo de pagamento
- Flag de migração ASAAS → Pagar.me implementada
