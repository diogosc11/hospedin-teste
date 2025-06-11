class Api::V1::WebhooksController < ApplicationController
  def pagarme
    begin
      Rails.logger.info "Webhook recebido: #{params[:type]}"
      Rails.logger.info "Payload: #{request.raw_post}"
      
      event_type = params[:type]
      event_data = params[:data]
      pagar_me_order_id = event_data&.dig('id')
      
      payment = Payment.find_by(pagar_me_order_id: pagar_me_order_id)
      
      unless payment
        Rails.logger.warn "Pagamento não encontrado para order_id: #{pagar_me_order_id}"
        return render json: { success: true, message: 'Pagamento não encontrado, ignorando webhook' }, status: :ok
      end
      
      case event_type
      when 'payment.confirmed', 'order.paid'
        handle_payment_confirmed(payment, event_data)
      when 'payment.failed', 'order.payment_failed'
        handle_payment_failed(payment, event_data)
      when 'subscription.created'
        handle_subscription_created(payment, event_data)
      when 'subscription.updated'
        handle_subscription_updated(payment, event_data)
      when 'invoice.paid'
        handle_invoice_paid(payment, event_data)
      else
        Rails.logger.info "ℹEvento não processado: #{event_type}"
      end
      
      render json: { 
        success: true, 
        message: 'Webhook processado com sucesso',
        payment_id: payment.id,
        event_type: event_type
      }, status: :ok
      
    rescue => e
      Rails.logger.error "Erro ao processar webhook: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: { 
        success: false, 
        message: 'Erro ao processar webhook',
        error: e.message
      }, status: :internal_server_error
    end
  end

  private

  def handle_payment_confirmed(payment, event_data)
    return if payment.confirmado?
    
    Rails.logger.info "Confirmando pagamento #{payment.id} via webhook"
    
    paid_amount = event_data.dig('charges', 0, 'paid_amount')
    paid_amount = paid_amount ? paid_amount / 100.0 : payment.valor
    
    payment.update!(
      status: 'confirmado',
      data_pagamento: Time.current,
      pagar_me_response: event_data,
      processed_at: Time.current
    )
    
    Rails.logger.info "Pagamento #{payment.id} confirmado: #{payment.valor_formatado}"
    
    send_confirmation_notification(payment)
  end

  def handle_payment_failed(payment, event_data)
    return if payment.falhou?
    
    Rails.logger.info "Marcando pagamento #{payment.id} como falhou via webhook"
    
    failure_reason = extract_failure_reason(event_data)
    
    payment.update!(
      status: 'falhou',
      pagar_me_response: event_data.merge(failure_reason: failure_reason),
      processed_at: Time.current
    )
    
    Rails.logger.info "Pagamento #{payment.id} falhou: #{failure_reason}"

    send_failure_notification(payment, failure_reason)
  end

  def handle_subscription_created(payment, event_data)
    return unless payment.recorrente?
    
    Rails.logger.info "Assinatura criada para pagamento #{payment.id}"
    
    subscription_data = event_data['subscription'] || {}
    
    payment.update!(
      pagar_me_response: payment.pagar_me_response.merge(subscription: subscription_data),
      processed_at: Time.current
    )
    
    Rails.logger.info "Assinatura #{subscription_data['id']} ativada"
  end

  def handle_subscription_updated(payment, event_data)
    handle_subscription_created(payment, event_data)
  end

  def handle_invoice_paid(payment, event_data)
    return unless payment.recorrente?
    
    Rails.logger.info "Fatura paga para assinatura do pagamento #{payment.id}"
    
    create_recurring_payment_record(payment, event_data)
  end

  def extract_failure_reason(event_data)
    transaction = event_data.dig('charges', 0, 'last_transaction')
    
    if transaction
      return transaction['acquirer_message'] || 'Falha na transação'
    end
    
    'Pagamento não autorizado'
  end

  def send_confirmation_notification(payment)
    Rails.logger.info "Enviando notificação de confirmação para #{payment.client.email}"
  end

  def send_failure_notification(payment, reason)
    Rails.logger.info "Enviando notificação de falha para #{payment.client.email}: #{reason}"
  end

  def create_recurring_payment_record(original_payment, event_data)
    new_payment = Payment.create!(
      client: original_payment.client,
      product: original_payment.product,
      valor: original_payment.valor,
      status: 'confirmado',
      tipo_cobranca: 'recorrente',
      data_pagamento: Time.current,
      pagar_me_order_id: event_data['id'],
      pagar_me_response: event_data,
      processed_at: Time.current
    )
    
    Rails.logger.info "Nova cobrança recorrente criada: pagamento #{new_payment.id}"
    
    new_payment
  end
end