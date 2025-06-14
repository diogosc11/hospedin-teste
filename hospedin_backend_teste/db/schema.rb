# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_13_183833) do
  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "company"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_type"
    t.string "document"
    t.string "document_type"
    t.string "gender"
    t.date "birthdate"
    t.json "address"
    t.json "phones"
    t.boolean "migrando_para_pagarme", default: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "product_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.string "status", default: "pendente", null: false
    t.datetime "data_pagamento"
    t.string "tipo_cobranca", null: false
    t.string "pagar_me_order_id"
    t.json "pagar_me_response"
    t.json "webhook_payload"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_payments_on_client_id"
    t.index ["product_id"], name: "index_payments_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "payments", "clients"
  add_foreign_key "payments", "products"
end
