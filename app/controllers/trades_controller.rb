require 'csv'

class TradesController < ApplicationController
    def new
      @trade = Trade.new
      @trade.trade_date = Date.today
    end

    def create
      @trade = Trade.new trade_params.merge(user_id: current_user.id)

      if @trade.save
        redirect_to :root
      else
        render :new
      end
    end

    def edit
      @trade = Trade.find params[:id]
    end

    def update
      @trade = Trade.find params[:id]

      if @trade.update trade_params
        redirect_to :root
      else
        render :edit
      end
    end

    def import
      CSV.foreach(params[:file].path, headers: true) do |row|
        trade = row.to_h

        date, time = trade['DateTime'].split ';'
        year = date[0...4]
        month = date[4...6]
        day = date[6...8]
        hour = time[0...2]
        minute = time[2...4]
        second = time[4...6]

        next if Trade.find_by trade_id: trade['TradeID'], platform: 'IB'

        Trade.create symbol: trade['Symbol'],
                     currency: trade['CurrencyPrimary'],
                     price: trade['TradePrice'].to_d,
                     quantity: trade['Quantity'].to_f,
                     platform: 'IB',
                     trade_id: trade['TradeID'],
                     commission: trade['IBCommission'].to_d.abs,
                     trade_date: Time.new(year, month, day, hour, minute, second),
                     is_imported: true,
                     user_id: current_user.id

      end

      redirect_to :root
    end

    def new_trades_import
    end

    private

    def trade_params
      secure_params = params.require(:trade).permit(:symbol, :price, :quantity, :commission, :notes, :trade_date, :currency)
      secure_params[:symbol] = secure_params[:symbol].upcase if secure_params[:symbol]
      secure_params[:currency] = secure_params[:currency].upcase if secure_params[:currency]
      secure_params[:price] = secure_params[:price].to_d if secure_params[:price]
      secure_params[:commission] = secure_params[:commission].to_d if secure_params[:commission]
      secure_params[:quantity] = secure_params[:quantity].to_f if secure_params[:quantity]
      secure_params
    end
end
