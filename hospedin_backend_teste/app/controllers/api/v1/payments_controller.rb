class Api::V1::PaymentsController < ApplicationController
  def index
    payments = Payment.includes(:client, :product).order(created_at: :desc)

    if params[:name].present?
        payments = payments.joins(:product).where("LOWER(products.name) LIKE ?", "%#{params[:name].downcase}%")
    end

    if params[:status].present?
        payments = payments.where(status: params[:status])
    end

    if params[:payment_type].present?
        payments = payments.where(payment_type: params[:payment_type])
    end

    render json: {
      success: true,
      data: payments.map do |payment|
        {
          id: payment.id,
          pagar_me_order_id: payment.pagar_me_order_id,
          status: payment.status,
          status_label: payment.status_label,
          amount: payment.formatted_amount,
          payment_type: payment.payment_type_label,
          client_name: payment.client.name,
          product_name: payment.product.name,
          migrating_to_pagarme: payment.client.migrating_to_pagarme,
          paid_at: payment.paid_at,
          created_at: payment.created_at
        }
      end,
      meta: {
        total_count: payments.count,
        filters: {
          status: params[:status],
          payment_type: params[:payment_type],
          client_id: params[:client_id]
        }
      }
    }
  end

  def create
    begin
      client = Client.find(params[:client_id])
      product_ids = params[:product_ids] || [params[:product_id]]
      products = Product.where(id: product_ids)

      if products.empty?
        raise ActiveRecord::RecordNotFound, 'Nenhum produto encontrado'
      end

      payments = products.map do |product|
        payment = Payment.create!(
          client: client,
          product: product,
          amount: product.price,
          status: 'pending',
          payment_type: params[:payment_type]
        )
      end

      if payments.any?
        ProcessPaymentJob.perform_later(payments.map(&:id))
      end

      render json: {
        success: true,
        message: 'Pagamentos criados com sucesso',
        data: payments.map do |payment|
          {
            payment_id: payment.id,
            pagar_me_order_id: payment.pagar_me_order_id,
            client_name: payment.client.name,
            product_name: payment.product.name,
            amount: payment.formatted_amount,
            payment_type: payment.payment_type_label,
            status: payment.status_label,
            created_at: payment.created_at
          }
        end
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


  private

  def payment_params
    params.require(:payment).permit(:client_id, :product_id, :payment_type)
  end
end