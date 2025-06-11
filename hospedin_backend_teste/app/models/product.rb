class Product < ApplicationRecord
  has_many :payments

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  
  scope :active, -> { where(active: true) }
  scope :by_price_range, ->(min, max) { where(price: min..max) }
  
  def formatted_price
    "R$ #{price.to_f.round(2).to_s.gsub('.', ',')}"
  end
  
  def available_for_sale?
    active? && price > 0
  end
end