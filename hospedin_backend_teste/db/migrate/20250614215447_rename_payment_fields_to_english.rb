class RenamePaymentFieldsToEnglish < ActiveRecord::Migration[8.0]
  def change
    rename_column :payments, :valor, :amount
    rename_column :payments, :data_pagamento, :paid_at
    rename_column :payments, :tipo_cobranca, :payment_type
  end
end