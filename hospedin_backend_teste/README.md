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

## Executar testes

```bash
bundle exec rspec spec/models/payment_spec.rb --format documentation
```

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

## Arquitetura e Decisões Técnicas

- Separação de responsabilidades entre Models, Controllers e Jobs
- Processamento assíncrono para operações críticas
- Simulação realística do gateway de pagamento
- Flexibilidade para migração gradual ASAAS → Pagar.me

1. Processamento Assíncrono com Jobs
- Resposta rápida para o usuário
- Se o gateway falhar, não afeta a criação
- Pode processar milhares de pagamentos

2. Webhook Automático (Simula cenário real):
- Gateway processa → Envia webhook → Sistema atualiza status
- Tratamento de múltiplos eventos

3. Multi-produto por Transação (Casos de uso reais):
- Cliente compra "PMS + Motor de Reservas + Gestor de Canais"
- Cada produto tem sua cobrança individual
- Facilita relatórios por produto

4. Rails API:
- Sistema padronizado - desenvolvimento rápido
- Active Job nativo
- Active Record com validações

5. Por que Jobs em vez de Services?
- Processamento assíncrono
- Retry automático em caso de falha
- Facilidade de monitoramento

6. Validações Complexas no Model
- Regras de negócio centralizadas
- Reutilização
- Testabilidade
- Consistência

## Próximos Passos

- Dashboard de faturamento e histórico de webhooks
- Aumento da cobertura de testes com RSpec
- Integração real com Pagar.me

## Diferenciais

- Webhook completo com múltiplos tipos de eventos
- Processamento assíncrono com simulação de delay
- Multi-produtos por cliente no mesmo fluxo de pagamento
- Flag de migração ASAAS → Pagar.me implementada

## Possíveis Desafios na Migração ASAAS → Pagar.me

Durante a migração de um sistema descentralizado (como o ASAAS) para o Pagar.me, alguns desafios esperados são:

- Garantir que os clientes que ainda estão sendo cobrados via ASAAS não sofram cobrança duplicada.
- Criar uma rotina de corte automático no ASAAS conforme a ativação no Pagar.me.
- Manter histórico de cobranças anteriores.
- Criar uma comunicação clara com o cliente final sobre a mudança no método de cobrança.
