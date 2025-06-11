class RenameTypeToClientTypeInClients < ActiveRecord::Migration[8.0]
  def change
    rename_column :clients, :type, :client_type
  end
end
