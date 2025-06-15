FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Produto #{n}" }
    sequence(:description) { |n| "Descrição do produto #{n}" }
    price { 99.90 }
    active { true }
  end
end