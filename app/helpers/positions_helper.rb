class PositionsHelper
  def self.generate(trades)
    new(trades).generate
  end

  def initialize(trades)
    @trades = trades
    @positions = {}
    @pnl = []
  end

  def generate
    @trades.each do |trade|
      try_generate_pnl_from trade

      if is_new_position?(trade)
        @positions[trade.symbol] = {
          currency: trade.currency,
          quantity: trade.quantity,
          price: (trade.price * trade.quantity + trade.commission) / trade.quantity,
          created_at: trade.trade_date
        }
      elsif should_close_position?(trade)
        @positions = @positions.except(trade.symbol)
      elsif is_increasing_position?(trade)
        price = (@positions[trade.symbol][:price] * @positions[trade.symbol][:quantity] + trade.price * trade.quantity + trade.commission).abs / (trade.quantity.abs + @positions[trade.symbol][:quantity].abs)
        quantity = trade.quantity + @positions[trade.symbol][:quantity]

        @positions[trade.symbol][:quantity] = quantity
        @positions[trade.symbol][:price] = price
      else
        quantity = trade.quantity + @positions[trade.symbol][:quantity]
        @positions[trade.symbol][:quantity] = quantity
      end
    end

    [@pnl, @positions]
  end

  private

  def try_generate_pnl_from(trade)
    @pnl << generate_pnl(trade) if should_generate_pnl?(trade)
  end

  def should_generate_pnl?(trade)
    return false if @positions[trade.symbol].nil?
    return false if is_increasing_position?(trade)

    true
  end

  def generate_pnl(trade)
    pnl = {symbol: trade.symbol, currency: trade.currency, trade_date: trade.trade_date, quantity: trade.quantity.abs}

    if is_reducing_long?(trade)
      pnl[:price] = (trade.price - @positions[trade.symbol][:price]) * trade.quantity.abs - trade.commission
    elsif is_covering_short?(trade)
      pnl[:price] = (@positions[trade.symbol][:price] - trade.price) * trade.quantity.abs - trade.commission
    else
      raise StandardError, 'Invalid operation'
    end

    pnl[:percent_pnl] = (pnl[:price] / (pnl[:quantity] * @positions[trade.symbol][:price])).abs * 100

    pnl
  end

  def is_reducing_long?(trade)
    @positions[trade.symbol][:quantity] > 0 && trade.quantity < 0
  end

  def is_covering_short?(trade)
    @positions[trade.symbol][:quantity] < 0 && trade.quantity > 0
  end

  def is_new_position?(trade)
    @positions[trade.symbol].nil?
  end

  def should_close_position?(trade)
    @positions[trade.symbol][:quantity] + trade.quantity == 0
  end

  def is_increasing_position?(trade)
    (@positions[trade.symbol][:quantity] > 0 && trade.quantity > 0) || (@positions[trade.symbol][:quantity] < 0 && trade.quantity < 0)
  end
end