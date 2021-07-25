class DashboardController < ApplicationController
  def index
    @trades = Trade.where(user_id: current_user.id).order :trade_date
    @dashboard_service = DashboardService.generate @trades

    @pnls = @dashboard_service.pnls
    @positions = @dashboard_service.positions
    @pnls_stats = @dashboard_service.pnls_stats
  end

  def show
    @trades = Trade.where(symbol: params[:id], user_id: current_user.id).order :trade_date
    @dashboard_service = DashboardService.generate @trades

    @pnls = @dashboard_service.pnls
    @positions = @dashboard_service.positions
    @pnls_stats = @dashboard_service.pnls_stats

    render :index
  end
end