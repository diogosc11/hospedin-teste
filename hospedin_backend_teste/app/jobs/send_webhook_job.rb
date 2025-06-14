class SendWebhookJob < ApplicationJob
  queue_as :default

  def perform(payment_ids, event_type)
    payments = Payment.where(id: payment_ids)
    first = payments.first

    webhook_payload = {
      id: "evt_#{SecureRandom.hex(6)}",
      type: event_type,
      created_at: Time.current.iso8601,
      data: {
        id: first.pagar_me_order_id,
        amount: (payments.sum(&:amount) * 100).to_i,
        status: map_status(first.status),
        customer: {
          name: first.client.name,
          email: first.client.email
        },
        metadata: {
          payment_ids: payments.map(&:id),
          products: payments.map { |p| p.product.name }
        }
      }
    }

    simulate_webhook_call(webhook_payload)
    payments.each { |p| p.update!(webhook_payload: webhook_payload) }

    Rails.logger.info "Webhook enviado para pagamentos: #{payment_ids.join(', ')}"
  end

  private

  def map_status(status)
    case status
    when 'pending' then 'pending'
    when 'confirmed' then 'paid'
    when 'failed' then 'failed'
    else 'pending'
    end
  end

  def simulate_webhook_call(payload)
    sleep(0.5)

    send_webhook_http(payload)
  end

  def send_webhook_http(payload)
    begin
      require 'net/http'
      require 'uri'
      
      uri = URI('http://localhost:3000/api/v1/webhooks/pagarme')
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      
      response = http.request(request)
      Rails.logger.info "Webhook response: #{response.code}"
      
    rescue => e
      Rails.logger.error "Erro HTTP webhook: #{e.message}"
    end
  end
end