class TradesController < ApplicationController
    def new
      @trade = Trade.new
      @trade.trade_date = Date.today
    end

    def create
      trade = Trade.new trade_params

      if trade.save
        redirect_to :root
      else
        render :new
      end
    end

    private

    def trade_params
      secure_params = params.require(:trade).permit(:symbol, :price, :quantity, :commission, :notes, :trade_date, :currency)
      secure_params[:symbol] = secure_params[:symbol].upcase
      secure_params[:currency] = secure_params[:currency].upcase
      secure_params[:price] = secure_params[:price].to_d
      secure_params[:commission] = secure_params[:commission].to_d
      secure_params[:quantity] = secure_params[:quantity].to_f
      secure_params
    end
end
