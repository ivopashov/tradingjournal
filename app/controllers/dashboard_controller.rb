class DashboardController < ApplicationController
  def index
    @trades = Trade.order :trade_date
    @pnls, @positions = PositionsHelper.generate @trades
  end
end