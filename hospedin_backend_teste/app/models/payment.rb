class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :product

  before_create :generate_public_id
  before_validation :generate_pagar_me_id, on: :create

  enum :status, { pending: 'pending', confirmed: 'confirmed', failed: 'failed' }
  enum :payment_type, { one_time: 'one_time', recurring: 'recurring' }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending confirmed failed] }
  validates :payment_type, inclusion: { in: %w[one_time recurring] }

  def processed?
    processed_at.present?
  end

  def formatted_amount
    ActionController::Base.helpers.number_to_currency(amount, unit: 'R$ ', separator: ',', delimiter: '.')
  end

  def status_label
    case status
    when 'pending'
      'Pendente'
    when 'confirmed'
      'Confirmado'
    when 'failed'
      'Falhou'
    end
  end

  def payment_type_label
    case payment_type
    when 'one_time'
      'Pagamento Único'
    when 'recurring'
      'Assinatura Mensal'
    end
  end

  def confirm!(pagar_me_data = {})
    update!(
      status: 'confirmed',
      paid_at: Time.current,
      pagar_me_response: pagar_me_data,
      processed_at: Time.current
    )
  end

  def fail!(error_data = {})
    update!(
      status: 'failed',
      pagar_me_response: error_data,
      processed_at: Time.current
    )
  end

  def mark_as_processed!
    update!(processed_at: Time.current) unless processed?
  end

  private

  def generate_public_id
    self.public_id = SecureRandom.uuid if public_id.blank?
  end

  def generate_pagar_me_id
    self.pagar_me_order_id = "or_#{SecureRandom.hex(8)}" if pagar_me_order_id.blank?
  end
end