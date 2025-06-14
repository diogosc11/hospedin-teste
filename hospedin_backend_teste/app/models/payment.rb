class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :product

  enum :status, { pendente: 'pendente', confirmado: 'confirmado', falhou: 'falhou' }
  enum :tipo_cobranca, { avulsa: 'avulsa', recorrente: 'recorrente' }

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pendente confirmado falhou] }
  validates :tipo_cobranca, inclusion: { in: %w[avulsa recorrente] }

  def processado?
    processed_at.present?
  end

  def valor_formatado
    "R$ #{valor.to_f.round(2).to_s.gsub('.', ',')}"
  end

  def status_humanizado
    case status
    when 'pendente'
      'Pendente'
    when 'confirmado'
      'Confirmado'
    when 'falhou'
      'Falhou'
    end
  end

  def tipo_cobranca_humanizado
    case tipo_cobranca
    when 'avulsa'
      'Pagamento Único'
    when 'recorrente'
      'Assinatura Mensal'
    end
  end

  def confirmar!(pagar_me_data = {})
    update!(
      status: 'confirmado',
      data_pagamento: Time.current,
      pagar_me_response: pagar_me_data,
      processed_at: Time.current
    )
  end

  def falhar!(erro_data = {})
    update!(
      status: 'falhou',
      pagar_me_response: erro_data,
      processed_at: Time.current
    )
  end

  def marcar_como_processado!
    update!(processed_at: Time.current) unless processado?
  end

  def gerar_pagar_me_id!
    self.pagar_me_order_id = "or_#{SecureRandom.hex(8)}" unless pagar_me_order_id.present?
    save!
  end
end