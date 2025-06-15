FactoryBot.define do
  factory :client do
    sequence(:name) { |n| "Cliente #{n}" }
    sequence(:email) { |n| "cliente#{n}@example.com" }
    sequence(:document) do |n|
      cpfs = ['11144477735', '22255588896', '33366699907', '44477700018', '55588811129']
      cpfs[n % cpfs.length]
    end
    client_type { 'individual' }
    document_type { 'CPF' }
    migrating_to_pagarme { false }
  end
end