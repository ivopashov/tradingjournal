require "securerandom"

class HeatMap < ApplicationRecord
    belongs_to :user

    before_create :generate_random_id
    validates :name, presence: true
    validates :tickers, presence: true
    validate :max_ticker_count

    # TODO validate it is alphanumeric?

    private

    def generate_random_id
        self.id = SecureRandom.uuid
    end

    def max_ticker_count
        if tickers.split(',').count > 25
          errors.add(:tickers_count, "can be up to 25")
        end
    end
end