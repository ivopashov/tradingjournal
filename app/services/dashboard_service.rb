require 'json'
require 'rest-client'

class DashboardService
  def self.generate(trades)
    new(trades)
  end

  attr_reader :trades, :positions, :pnls, :pnls_stats

  def initialize(trades)
    @trades = trades
    @positions = {}
    @pnls = []
    @pnls_stats = {
      winning_count: 0,
      losing_count: 0,
      average_winning_amount: 0,
      average_losing_amount: 0,
      average_winning_percentage: 0,
      average_losing_percentage: 0,
      winning_percentage: 0,
      losing_percentage: 0,
      total_profit: 0,
      total_loss: 0
    }

    generate_positions_pnls
    generate_pnls_stats
  end

  private

  def generate_pnls_stats
    return if @pnls.empty?
    winning, losing = @pnls.partition { |pnl| pnl[:price] > 0 }

    @pnls_stats[:winning_count] = winning.size
    @pnls_stats[:losing_count] = losing.size

    unless winning.empty?
      @pnls_stats[:average_winning_amount] = winning.map { |win| win[:price] }.sum / winning.size
      @pnls_stats[:average_winning_percentage] = winning.map { |win| win[:percent_pnl] }.sum / winning.size
      @pnls_stats[:total_profit] = winning.map { |win| win[:price] }.sum
    end

    unless losing.empty?
      @pnls_stats[:average_losing_amount] = losing.map { |loss| loss[:price] }.sum.abs / losing.size
      @pnls_stats[:average_losing_percentage] = losing.map { |loss| loss[:percent_pnl] }.sum / losing.size
      @pnls_stats[:total_loss] = losing.map { |loss| loss[:price] }.sum
    end

    @pnls_stats[:winning_percentage] = winning.size / @pnls.size.to_f * 100
    @pnls_stats[:losing_percentage] = losing.size / @pnls.size.to_f * 100
  end

  def generate_positions_pnls
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

    @positions.each do |ticker, value|
      url = "https://query1.finance.yahoo.com/v7/finance/chart/#{ticker}"
      result = JSON.parse RestClient.get url
      value[:market_price] = result['chart']['result'].first['meta']['regularMarketPrice']
      value[:distance_from_market_percentage] = ((value[:market_price] - value[:price]) / value[:price] * 100) * (value[:quantity] / value[:quantity].abs)
    end

    @positions = @positions.sort_by { |ticker, value| -value[:distance_from_market_percentage] }
  end

  def partial_profit_taking?(trade)
    ((trade.quantity + @positions[trade.symbol][:quantity]) * @positions[trade.symbol][:quantity]).positive?
  end

  def reversing_position?(trade)
    ((trade.quantity + @positions[trade.symbol][:quantity]) * @positions[trade.symbol][:quantity]).negative?
  end

  def try_generate_pnl_from(trade)
    if should_generate_pnl?(trade)
      pnl = generate_pnl(trade)
      pnl_id = "#{"%03d" % @pnls.size}-#{trade.symbol}"
      pnl[:id] = pnl_id
      @pnls << pnl
    end
  end

  def should_generate_pnl?(trade)
    return false if @positions[trade.symbol].nil?
    return false if is_increasing_position?(trade)

    true
  end

  def generate_pnl(trade)
    pnl = {symbol: trade.symbol, currency: trade.currency, trade_date_time: trade.trade_date, trade_date: trade.trade_date.to_date}

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
