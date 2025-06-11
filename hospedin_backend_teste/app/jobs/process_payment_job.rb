class ProcessPaymentJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    
    Rails.logger.info "Processando pagamento #{payment.id} - #{payment.pagar_me_order_id}"
    
    pagar_me_response = simulate_pagarme_api_call(payment)
    
    if pagar_me_response[:success]
      payment.confirmar!(pagar_me_response[:data])
      
      Rails.logger.info "Pagamento #{payment.id} confirmado"
      
      SendWebhookJob.perform_later(payment.id, 'payment.confirmed')
    else
      payment.falhar!(pagar_me_response[:error])
      
      Rails.logger.info "Pagamento #{payment.id} falhou"
      
      SendWebhookJob.perform_later(payment.id, 'payment.failed')
    end
    
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Pagamento #{payment_id} não encontrado"
  rescue => e
    Rails.logger.error "Erro ao processar pagamento #{payment_id}: #{e.message}"
    
    begin
      payment = Payment.find(payment_id)
      payment.falhar!({ error: e.message, processed_at: Time.current })
    rescue
    end
  end

  private

  def simulate_pagarme_api_call(payment)
    sleep(rand(1..3))
    
    mock_response = generate_pagarme_response(payment)
    
    success = simulate_payment_success(payment)
    
    if success
      {
        success: true,
        data: mock_response
      }
    else
      {
        success: false,
        error: {
          message: generate_error_message(payment),
          code: 'payment_failed',
          timestamp: Time.current.iso8601
        }
      }
    end
  end

  def generate_pagarme_response(payment)
    {
      "id" => payment.pagar_me_order_id,
      "code" => "#{SecureRandom.hex(4).upcase}",
      "amount" => (payment.valor * 100).to_i,
      "currency" => "BRL",
      "closed" => true,
      "items" => [
        {
          "id" => "oi_#{SecureRandom.hex(8)}",
          "type" => "product",
          "description" => payment.product.description,
          "amount" => (payment.valor * 100).to_i,
          "quantity" => 1,
          "status" => "active",
          "created_at" => Time.current.iso8601,
          "updated_at" => Time.current.iso8601
        }
      ],
      "customer" => {
        "id" => "cus_#{SecureRandom.hex(8)}",
        "name" => payment.client.name,
        "email" => payment.client.email,
        "delinquent" => false,
        "created_at" => payment.client.created_at.iso8601,
        "updated_at" => payment.client.updated_at.iso8601,
        "phones" => format_customer_phones(payment.client)
      },
      "status" => "paid",
      "created_at" => payment.created_at.iso8601,
      "updated_at" => Time.current.iso8601,
      "closed_at" => Time.current.iso8601,
      "charges" => [
        {
          "id" => "ch_#{SecureRandom.hex(8)}",
          "code" => "#{SecureRandom.hex(4).upcase}",
          "amount" => (payment.valor * 100).to_i,
          "paid_amount" => (payment.valor * 100).to_i,
          "status" => "paid",
          "currency" => "BRL",
          "payment_method" => payment.tipo_cobranca == 'avulsa' ? 'credit_card' : 'credit_card',
          "paid_at" => Time.current.iso8601,
          "created_at" => Time.current.iso8601,
          "updated_at" => Time.current.iso8601,
          "customer" => {
            "id" => "cus_#{SecureRandom.hex(8)}",
            "name" => payment.client.name,
            "email" => payment.client.email
          },
          "last_transaction" => {
            "operation_key" => rand(100000000..999999999).to_s,
            "id" => "tran_#{SecureRandom.hex(8)}",
            "transaction_type" => "credit_card",
            "gateway_id" => SecureRandom.uuid,
            "amount" => (payment.valor * 100).to_i,
            "status" => "captured",
            "success" => true,
            "installments" => 1,
            "installment_type" => "merchant",
            "statement_descriptor" => "HOSPEDIN",
            "acquirer_name" => "simulator",
            "acquirer_tid" => rand(100000000..999999999).to_s,
            "acquirer_nsu" => rand(10000..99999).to_s,
            "acquirer_auth_code" => rand(10..99).to_s,
            "acquirer_message" => "Transação capturada com sucesso",
            "acquirer_return_code" => "00",
            "entry_mode" => "ecommerce",
            "operation_type" => "auth_and_capture",
            "created_at" => Time.current.iso8601,
            "updated_at" => Time.current.iso8601,
            "gateway_response" => {
              "code" => "200",
              "errors" => []
            }
          }
        }
      ]
    }
  end

    def simulate_payment_success(payment)
    base_success_rate = 90

    valor = payment.valor.to_f

    if valor > 1000
        base_success_rate = 95
    elsif valor < 10
        base_success_rate = 85
    end

    sorteado = rand(100)

    sorteado < base_success_rate
    end

  def generate_error_message(payment)
    error_messages = [
      "Cartão recusado pela operadora",
      "Limite insuficiente",
      "Cartão expirado",
      "Dados do cartão inválidos",
      "Transação não autorizada",
      "Falha na comunicação com a operadora"
    ]
    
    error_messages.sample
  end

  def format_customer_phones(client)
    return {} unless client.phones&.dig('mobile_phone')
    
    mobile = client.phones['mobile_phone']
    {
      "mobile_phone" => {
        "country_code" => mobile['country_code'] || '55',
        "area_code" => mobile['area_code'],
        "number" => mobile['number']
      }
    }
  end
end