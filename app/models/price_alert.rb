class PriceAlert < ApplicationRecord
    belongs_to :user

    validate :positive_price, :valid_comparison_operator

    validates :ticker, presence: true
    validates :name, presence: true
    validates :price, presence: true
    validates :comparison_operator, presence: true

    before_save { self.ticker.upcase! }

    def positive_price
        if price <= 0
          errors.add(:price, "should be positive number")
        end
    end

    def valid_comparison_operator
        unless comparison_operator.in? ["<", ">", ">=", "<="]
          errors.add(:comparison_operator, "can be only <, >, >=, <=")
        end
    end
end