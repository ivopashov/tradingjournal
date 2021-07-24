class DashboardService
  def self.generate(trades)
    new(trades).generate
  end

  attr_reader :trades, :positions, :pnl

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

        next
      end

      if is_increasing_position?(trade)
        price = (@positions[trade.symbol][:price] * @positions[trade.symbol][:quantity] + trade.price * trade.quantity + trade.commission).abs / (trade.quantity.abs + @positions[trade.symbol][:quantity].abs)
        quantity = trade.quantity + @positions[trade.symbol][:quantity]

        @positions[trade.symbol][:quantity] = quantity
        @positions[trade.symbol][:price] = price

        next
      end

      if should_close_position?(trade)
        @positions = @positions.except(trade.symbol)

        next
      end

      if partial_profit_taking?(trade)
        quantity = trade.quantity + @positions[trade.symbol][:quantity]
        @positions[trade.symbol][:quantity] = quantity

        next
      end

      if reversing_position?(trade)
        quantity = trade.quantity + @positions[trade.symbol][:quantity]
        @positions[trade.symbol][:quantity] = quantity
        @positions[trade.symbol][:price] = trade.price
        @positions[trade.symbol][:created_at] = trade.trade_date
      end
    end

    [@pnl, @positions]
  end

  private

  def partial_profit_taking?(trade)
    ((trade.quantity + @positions[trade.symbol][:quantity]) * @positions[trade.symbol][:quantity]).positive?
  end

  def reversing_position?(trade)
    ((trade.quantity + @positions[trade.symbol][:quantity]) * @positions[trade.symbol][:quantity]).negative?
  end

  def try_generate_pnl_from(trade)
    @pnl << generate_pnl(trade) if should_generate_pnl?(trade)
  end

  def should_generate_pnl?(trade)
    return false if @positions[trade.symbol].nil?
    return false if is_increasing_position?(trade)

    true
  end

  def generate_pnl(trade)
    pnl = {symbol: trade.symbol, currency: trade.currency, trade_date: trade.trade_date}

    if is_reducing_long?(trade)
      pnl[:price] = (trade.price - @positions[trade.symbol][:price]) * [trade.quantity.abs, @positions[trade.symbol][:quantity].abs].min  - trade.commission
    elsif is_covering_short?(trade)
      pnl[:price] = (@positions[trade.symbol][:price] - trade.price) * [trade.quantity.abs, @positions[trade.symbol][:quantity].abs].min - trade.commission
    else
      raise StandardError, 'Invalid operation'
    end

    pnl[:percent_pnl] = (pnl[:price] / ([trade.quantity.abs, @positions[trade.symbol][:quantity].abs].min * @positions[trade.symbol][:price])).abs * 100

    pnl
  end

  def is_reducing_long?(trade)
    @positions[trade.symbol][:quantity].positive? && trade.quantity.negative?
  end

  def is_covering_short?(trade)
    @positions[trade.symbol][:quantity].negative? && trade.quantity.positive?
  end

  def is_new_position?(trade)
    @positions[trade.symbol].nil?
  end

  def should_close_position?(trade)
    (@positions[trade.symbol][:quantity] + trade.quantity).zero?
  end

  def is_increasing_position?(trade)
    (@positions[trade.symbol][:quantity] * trade.quantity).positive?
  end
end
