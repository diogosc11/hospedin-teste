class RenameClientMigrandoParaPagarmeToMigratingToPagarme < ActiveRecord::Migration[8.0]
  def change
    rename_column :clients, :migrando_para_pagarme, :migrating_to_pagarme
  end
end