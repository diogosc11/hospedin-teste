class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :client, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pendente'
      t.datetime :data_pagamento
      t.string :tipo_cobranca, null: false
      t.string :pagar_me_order_id
      t.json :pagar_me_response
      t.json :webhook_payload
      t.datetime :processed_at

      t.timestamps
    end
  end
end
