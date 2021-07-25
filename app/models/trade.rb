class Trade < ApplicationRecord
    belongs_to :user

    validates :symbol, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :quantity, presence: true
    validates :commission, numericality: { greater_than_or_equal_to: 0 }
    validates :trade_date, presence: true
    validates :notes, length: { maximum: 2000 }
end
