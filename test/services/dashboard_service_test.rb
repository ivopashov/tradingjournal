require "test_helper"

class DashboardServiceTest < ActiveSupport::TestCase
  test "positions after initializing long position" do
    trade = Trade.new symbol: 'AAPL',
                      currency: 'USD',
                      price: 1,
                      quantity: 1,
                      commission: 1,
                      trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    pnls, positions = DashboardService.generate [trade]

    assert_equal 1, positions.size
    assert_equal 0, pnls.size

    assert_equal 2, positions['AAPL'][:price]
    assert_equal 'USD', positions['AAPL'][:currency]
    assert_equal trade.trade_date, positions['AAPL'][:created_at]
    assert_equal 1, positions['AAPL'][:quantity]
  end

  test "positions after adding to long position" do
    initial_trade = Trade.new symbol: 'AAPL',
                              currency: 'USD',
                              price: 1,
                              quantity: 1,
                              commission: 1,
                              trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    additional_trade = Trade.new symbol: 'AAPL',
                                 currency: 'USD',
                                 price: 2,
                                 quantity: 1,
                                 commission: 2,
                                 trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    pnls, positions = DashboardService.generate [initial_trade, additional_trade]

    assert_equal 1, positions.size
    assert_equal 0, pnls.size

    assert_equal 3, positions['AAPL'][:price]
    assert_equal 2, positions['AAPL'][:quantity]
  end

  test "positions after initializing short position" do
    trade = Trade.new symbol: 'AAPL',
                      currency: 'USD',
                      price: 2,
                      quantity: -1,
                      commission: 1,
                      trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    pnls, positions = DashboardService.generate [trade]

    assert_equal 1, positions.size
    assert_equal 0, pnls.size

    assert_equal 1, positions['AAPL'][:price]
    assert_equal 'USD', positions['AAPL'][:currency]
    assert_equal trade.trade_date, positions['AAPL'][:created_at]
    assert_equal -1, positions['AAPL'][:quantity]
  end

  test "positions after adding to short position" do
    initial_trade = Trade.new symbol: 'AAPL',
                              currency: 'USD',
                              price: 10,
                              quantity: -1,
                              commission: 1,
                              trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    additional_trade = Trade.new symbol: 'AAPL',
                                 currency: 'USD',
                                 price: 9,
                                 quantity: -1,
                                 commission: 1,
                                 trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    pnls, positions = DashboardService.generate [initial_trade, additional_trade]

    assert_equal 1, positions.size
    assert_equal 0, pnls.size

    assert_equal 8.5, positions['AAPL'][:price]
    assert_equal -2, positions['AAPL'][:quantity]
  end

  test "pnl after selling from long position" do
    buy_position_trade = Trade.new symbol: 'AAPL',
                                   currency: 'USD',
                                   price: 1,
                                   quantity: 2,
                                   commission: 2,
                                   trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    sell_partial_long_position_trade = Trade.new symbol: 'AAPL',
                                                 currency: 'USD',
                                                 price: 5,
                                                 quantity: -1,
                                                 commission: 1,
                                                 trade_date: Time.new(2021, 07, 8, 07, 07, 07)

    pnls, positions = DashboardService.generate [buy_position_trade, sell_partial_long_position_trade]

    assert_equal 1, positions.size
    assert_equal 1, pnls.size

    assert_equal 2, positions['AAPL'][:price]
    assert_equal 'USD', positions['AAPL'][:currency]
    assert_equal buy_position_trade.trade_date, positions['AAPL'][:created_at]
    assert_equal 1, positions['AAPL'][:quantity]

    assert_equal 'AAPL', pnls.first[:symbol]
    assert_equal 2, pnls.first[:price]
    assert_equal 'USD', pnls.first[:currency]
    assert_equal sell_partial_long_position_trade.trade_date, pnls.first[:trade_date]
    assert_equal 100, pnls.first[:percent_pnl]
  end

  test "pnl after covering from short position" do
    sell_position_trade = Trade.new symbol: 'AAPL',
                                    currency: 'USD',
                                    price: 11,
                                    quantity: -2,
                                    commission: 2,
                                    trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    cover_partial_short_position_trade = Trade.new symbol: 'AAPL',
                                                   currency: 'USD',
                                                   price: 5,
                                                   quantity: 1,
                                                   commission: 1,
                                                   trade_date: Time.new(2021, 07, 8, 07, 07, 07)

    pnls, positions = DashboardService.generate [sell_position_trade, cover_partial_short_position_trade]

    assert_equal 1, positions.size
    assert_equal 1, pnls.size

    assert_equal 10, positions['AAPL'][:price]
    assert_equal 'USD', positions['AAPL'][:currency]
    assert_equal sell_position_trade.trade_date, positions['AAPL'][:created_at]
    assert_equal -1, positions['AAPL'][:quantity]

    assert_equal 'AAPL', pnls.first[:symbol]
    assert_equal 4, pnls.first[:price]
    assert_equal 'USD', pnls.first[:currency]
    assert_equal cover_partial_short_position_trade.trade_date, pnls.first[:trade_date]
    assert_equal 40, pnls.first[:percent_pnl]
  end

  test "closes position" do
    buy_position = Trade.new symbol: 'AAPL',
                             currency: 'USD',
                             price: 1,
                             quantity: 1,
                             commission: 2,
                             trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    sell_position = Trade.new symbol: 'AAPL',
                            currency: 'USD',
                            price: 5,
                            quantity: -1,
                            commission: 1,
                            trade_date: Time.new(2021, 07, 8, 07, 07, 07)

    pnls, positions = DashboardService.generate [buy_position, sell_position]

    assert_equal 0, positions.size
  end

  test "reverses long to short position" do
    buy_position = Trade.new symbol: 'AAPL',
                             currency: 'USD',
                             price: 9,
                             quantity: 1,
                             commission: 1,
                             trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    sell_position = Trade.new symbol: 'AAPL',
                              currency: 'USD',
                              price: 9,
                              quantity: -2,
                              commission: 1,
                              trade_date: Time.new(2021, 07, 8, 07, 07, 07)

    pnls, positions = DashboardService.generate [buy_position, sell_position]

    assert_equal 1, positions.size
    assert_equal 1, pnls.size

    assert_equal 9, positions['AAPL'][:price]
    assert_equal 'USD', positions['AAPL'][:currency]
    assert_equal sell_position.trade_date, positions['AAPL'][:created_at]
    assert_equal -1, positions['AAPL'][:quantity]

    assert_equal 'AAPL', pnls.first[:symbol]
    assert_equal -2, pnls.first[:price]
    assert_equal 'USD', pnls.first[:currency]
    assert_equal sell_position.trade_date, pnls.first[:trade_date]
    assert_equal 20, pnls.first[:percent_pnl]
  end

  test "reverses shprt to long position" do
    sell_position = Trade.new symbol: 'AAPL',
                              currency: 'USD',
                              price: 9,
                              quantity: -1,
                              commission: 1,
                              trade_date: Time.new(2021, 07, 07, 07, 07, 07)

    buy_position = Trade.new symbol: 'AAPL',
                             currency: 'USD',
                             price: 9,
                             quantity: 2,
                             commission: 1,
                             trade_date: Time.new(2021, 07, 8, 07, 07, 07)

    pnls, positions = DashboardService.generate [sell_position, buy_position]

    assert_equal 1, positions.size
    assert_equal 1, pnls.size

    assert_equal 9, positions['AAPL'][:price]
    assert_equal 'USD', positions['AAPL'][:currency]
    assert_equal buy_position.trade_date, positions['AAPL'][:created_at]
    assert_equal 1, positions['AAPL'][:quantity]

    assert_equal 'AAPL', pnls.first[:symbol]
    assert_equal -2, pnls.first[:price]
    assert_equal 'USD', pnls.first[:currency]
    assert_equal buy_position.trade_date, pnls.first[:trade_date]
    assert_equal 25, pnls.first[:percent_pnl]
  end
end
