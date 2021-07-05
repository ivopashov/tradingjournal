class Position < ApplicationRecord
  validates :symbol, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true
end
