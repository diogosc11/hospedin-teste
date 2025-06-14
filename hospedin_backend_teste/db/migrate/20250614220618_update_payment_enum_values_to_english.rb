class UpdatePaymentEnumValuesToEnglish < ActiveRecord::Migration[8.0]
  def up
    Payment.where(status: 'pendente').update_all(status: 'pending')
    Payment.where(status: 'confirmado').update_all(status: 'confirmed')
    Payment.where(status: 'falhou').update_all(status: 'failed')
    
    Payment.where(payment_type: 'avulsa').update_all(payment_type: 'one_time')
    Payment.where(payment_type: 'recorrente').update_all(payment_type: 'recurring')
  end

  def down
    Payment.where(status: 'pending').update_all(status: 'pendente')
    Payment.where(status: 'confirmed').update_all(status: 'confirmado')
    Payment.where(status: 'failed').update_all(status: 'falhou')
    
    Payment.where(payment_type: 'one_time').update_all(payment_type: 'avulsa')
    Payment.where(payment_type: 'recurring').update_all(payment_type: 'recorrente')
  end
end