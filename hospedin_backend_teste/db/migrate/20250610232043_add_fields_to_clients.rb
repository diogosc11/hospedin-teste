class AddFieldsToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :type, :string
    add_column :clients, :document, :string
    add_column :clients, :document_type, :string
    add_column :clients, :gender, :string
    add_column :clients, :birthdate, :date
    add_column :clients, :address, :json
    add_column :clients, :phones, :json
  end
end
