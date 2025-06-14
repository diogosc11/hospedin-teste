class Api::V1::ClientsController < ApplicationController
  before_action :set_client, only: [:show, :update, :destroy]

  def index
    @clients = Client.all
    
    render json: @clients
  end

  def show
    render json: @client
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      render json: {
        client: @client,
        message: "Cliente criado com sucesso"
      }, status: :created
    else
      render json: {
        errors: @client.errors.full_messages,
        details: @client.errors
      }, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(client_params)
      render json: {
        client: @client,
        message: "Cliente atualizado com sucesso"
      }
    else
      render json: {
        errors: @client.errors.full_messages,
        details: @client.errors
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @client.payments.exists?
      render json: { 
        error: "Não é possível remover cliente com pagamentos associados" 
      }, status: :unprocessable_entity
    else
      @client.destroy
      render json: { message: "Cliente removido com sucesso" }
    end
  end

  private

  def set_client
    @client = Client.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Cliente não encontrado" }, status: :not_found
  end

  def client_params
    params.require(:client).permit(
      :name, 
      :email, 
      :phone, 
      :company,
      :client_type,
      :document,
      :document_type,
      :gender,
      :birthdate,
      :migrating_to_pagarme,
      address: [
        :country,
        :state,
        :city,
        :zip_code,
        :line_1,
        :line_2
      ],
      phones: [
        mobile_phone: [
          :country_code,
          :area_code,
          :number
        ]
      ]
    )
  end
end