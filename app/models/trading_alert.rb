class TradingAlert < ApplicationRecord
    belongs_to :user

    validate :valid_rule

    validates :ticker, presence: true
    validates :rule, presence: true

    before_save do
      self.ticker.strip!
      self.ticker.upcase!
    end

    def valid_rule
      # TODO improve
      delimiters = ['>', '<', '<=', '>=']
      rule_parts = rule.split(Regexp.union(delimiters)).map { |token| token.strip }
      if rule_parts.size != 2 || rule_parts[0].upcase != "PRICE" || !is_number?(rule_parts[1])
        errors.add(:rule, "invalid format. Should be 'price >= 42.42'")
      end
    end

    def is_number? string
      true if Float(string) rescue false
    end
end