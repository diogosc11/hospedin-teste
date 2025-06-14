class ProcessPaymentJob < ApplicationJob
  queue_as :default

  def perform(payment_id_or_ids)
    payment_ids = Array(payment_id_or_ids)
    payments = Payment.where(id: payment_ids)
    
    Rails.logger.info "Processando #{payments.count} pagamentos: #{payment_ids.join(', ')}"
    
    pagar_me_response = simulate_pagarme_api_call(payments.to_a)
    
    if pagar_me_response[:success]
      payments.each { |payment| payment.confirm!(pagar_me_response[:data]) }
      
      Rails.logger.info "Pagamentos confirmados: #{payment_ids.join(', ')}"
      
      SendWebhookJob.perform_later(payment_ids, 'payment.confirmed')
    else
      payments.each { |payment| payment.fail!(pagar_me_response[:error]) }
      
      Rails.logger.info "Pagamentos falharam: #{payment_ids.join(', ')}"
      
      SendWebhookJob.perform_later(payment_ids, 'payment.failed')
    end
    
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Pagamentos não encontrados: #{payment_id_or_ids}"
  rescue => e
    Rails.logger.error "Erro ao processar pagamentos #{payment_id_or_ids}: #{e.message}"
    
    begin
      Payment.where(id: payment_ids).each do |payment|
        payment.fail!({ error: e.message, processed_at: Time.current })
      end
    rescue
      Rails.logger.error "Falha ao marcar pagamentos como erro"
    end
  end

  private

  def simulate_pagarme_api_call(payments)
    payments = Array(payments)
    
    total_amount = payments.sum(&:amount)
    client = payments.first.client

    sleep(rand(1..3))

    success = simulate_payment_success(total_amount)

    response = {
      id: payments.first.pagar_me_order_id,
      amount: (total_amount * 100).to_i,
      currency: "BRL",
      status: success ? "paid" : "failed",
      items: payments.map do |p|
        {
          id: "oi_#{SecureRandom.hex(8)}",
          type: "product",
          description: p.product.description,
          amount: (p.amount * 100).to_i,
          quantity: 1,
          payment_id: p.id
        }
      end,
      customer: {
        name: client.name,
        email: client.email
      },
      payments_count: payments.count,
      payment_ids: payments.map(&:id),
      created_at: Time.current.iso8601,
      updated_at: Time.current.iso8601
    }

    if success
      { success: true, data: response }
    else
      { 
        success: false, 
        error: { 
          message: generate_error_message(payments.first),
          payments_affected: payments.map(&:id),
          timestamp: Time.current.iso8601 
        } 
      }
    end
  end

  def simulate_payment_success(total_amount)
    base_success_rate = 90

    if total_amount > 1000
      base_success_rate = 95
    elsif total_amount < 10
      base_success_rate = 85
    end

    sorted = rand(100)
    sorted < base_success_rate
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