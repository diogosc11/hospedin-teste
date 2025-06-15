FactoryBot.define do
  factory :payment do
    association :client
    association :product
    amount { 99.90 }
    status { 'pending' }
    payment_type { 'one_time' }
    pagar_me_order_id { "or_#{SecureRandom.hex(8)}" }
  end
end