class DashboardController < ApplicationController
  def index
    @trades = Trade.order :trade_date
    @pnls, @positions = DashboardService.generate @trades
  end

  def show
    @trades = Trade.where(symbol: params[:id]).order :trade_date
    @pnls, @positions = DashboardService.generate @trades

    render :index
  end
end