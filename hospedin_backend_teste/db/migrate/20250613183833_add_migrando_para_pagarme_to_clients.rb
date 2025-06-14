class AddMigrandoParaPagarmeToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :migrando_para_pagarme, :boolean, default: false
  end
end
