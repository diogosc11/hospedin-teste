class Api::V1::PaymentsController < ApplicationController
  def create
    begin
      client = Client.find(params[:client_id])
      product = Product.find(params[:product_id])
      
      payment = Payment.create!(
        client: client,
        product: product,
        valor: product.price,
        status: 'pendente',
        tipo_cobranca: params[:tipo_cobranca]
      )

      payment.gerar_pagar_me_id!

      ProcessPaymentJob.perform_later(payment.id)

      render json: {
        success: true,
        message: 'Pagamento criado com sucesso! Processando...',
        data: {
          payment_id: payment.id,
          pagar_me_order_id: payment.pagar_me_order_id,
          client_name: client.name,
          product_name: product.name,
          valor: payment.valor_formatado,
          tipo_cobranca: payment.tipo_cobranca_humanizado,
          status: payment.status_humanizado,
          created_at: payment.created_at
        }
      }, status: :created

    rescue ActiveRecord::RecordNotFound => e
      render json: {
        success: false,
        message: 'Cliente ou produto não encontrado',
        errors: [e.message]
      }, status: :not_found

    rescue ActiveRecord::RecordInvalid => e
      render json: {
        success: false,
        message: 'Dados inválidos',
        errors: e.record.errors.full_messages
      }, status: :unprocessable_entity

    rescue => e
      Rails.logger.error "Erro ao criar pagamento: #{e.message}"
      render json: {
        success: false,
        message: 'Erro interno do servidor',
        errors: [e.message]
      }, status: :internal_server_error
    end
  end

  def show
    payment = Payment.find(params[:id])
    
    render json: {
      success: true,
      data: {
        id: payment.id,
        pagar_me_order_id: payment.pagar_me_order_id,
        status: payment.status,
        status_humanizado: payment.status_humanizado,
        valor: payment.valor_formatado,
        tipo_cobranca: payment.tipo_cobranca,
        tipo_cobranca_humanizado: payment.tipo_cobranca_humanizado,
        data_pagamento: payment.data_pagamento,
        processado: payment.processado?,
        client: {
          id: payment.client.id,
          name: payment.client.name,
          email: payment.client.email
        },
        product: {
          id: payment.product.id,
          name: payment.product.name,
          description: payment.product.description,
          price: "R$ #{payment.product.price.to_f.round(2).to_s.gsub('.', ',')}"
        },
        pagar_me_response: payment.pagar_me_response,
        webhook_payload: payment.webhook_payload,
        created_at: payment.created_at,
        updated_at: payment.updated_at
      }
    }
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      message: 'Pagamento não encontrado'
    }, status: :not_found
  end

  def index
    payments = Payment.includes(:client, :product).order(created_at: :desc)
    payments = payments.where(status: params[:status]) if params[:status].present?
    payments = payments.where(tipo_cobranca: params[:tipo_cobranca]) if params[:tipo_cobranca].present?
    payments = payments.where(client_id: params[:client_id]) if params[:client_id].present?

    limit = [params[:limit].to_i, 100].min
    limit = 20 if limit <= 0
    payments = payments.limit(limit)

    render json: {
      success: true,
      data: payments.map do |payment|
        {
          id: payment.id,
          pagar_me_order_id: payment.pagar_me_order_id,
          status: payment.status,
          status_humanizado: payment.status_humanizado,
          valor: payment.valor_formatado,
          tipo_cobranca: payment.tipo_cobranca_humanizado,
          client_name: payment.client.name,
          product_name: payment.product.name,
          data_pagamento: payment.data_pagamento,
          created_at: payment.created_at
        }
      end,
      meta: {
        total_count: payments.count,
        filters: {
          status: params[:status],
          tipo_cobranca: params[:tipo_cobranca],
          client_id: params[:client_id]
        }
      }
    }
  end

  def stats
    render json: {
      success: true,
      data: {
        total_payments: Payment.count,
        pendentes: Payment.pendentes.count,
        confirmados: Payment.confirmados.count,
        falharam: Payment.falharam.count,
        avulsas: Payment.avulsas.count,
        recorrentes: Payment.recorrentes.count,
        valor_total_confirmado: Payment.confirmados.sum(:valor),
        valor_total_pendente: Payment.pendentes.sum(:valor),
        ultimos_7_dias: Payment.where(created_at: 7.days.ago..Time.current).count
      }
    }
  end

  private

  def payment_params
    params.require(:payment).permit(:client_id, :product_id, :tipo_cobranca)
  end
end