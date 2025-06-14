class Product < ApplicationRecord
  has_many :payments

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  
  scope :active, -> { where(active: true) }
  scope :by_price_range, ->(min, max) { where(price: min..max) }
  
  def formatted_price
    ActionController::Base.helpers.number_to_currency(price, unit: 'R$ ', separator: ',', delimiter: '.')
  end
  
  def available_for_sale?
    active? && price > 0
  end
end