class PriceAlertsController < ApplicationController
    def index
        @active_price_alerts = PriceAlert.where user_id: current_user.id, triggered: false
        @recently_triggered_price_alerts = PriceAlert.where user_id: current_user.id, triggered: true, triggered_on: (10.days.ago..Time.now)
    end

    def new
        @price_alert = PriceAlert.new
    end

    def create
        @price_alert = PriceAlert.new price_alert_params.merge(user_id: current_user.id)

        if @price_alert.save
            DailyQuotes.delay.backfill [price_alert_params['ticker'].upcase]
            redirect_to action: :index
        else
            render :new, price_alert: @price_alert
        end
    end

    def destroy
        @price_alert = PriceAlert.find params["id"]
        @price_alert.destroy

        flash.notice = "Heat map '#{@price_alert.name}' was deleted"

        redirect_to action: :index
    end

    private

    def price_alert_params
        secure_params = params.require(:price_alert).permit(:name, :ticker, :price, :comparison_operator)
        secure_params[:price] = secure_params[:price].to_d if secure_params[:price]
        secure_params[:name] = secure_params[:name].strip if secure_params[:name]
        secure_params[:ticker] = secure_params[:ticker].strip.upcase if secure_params[:ticker]
        secure_params[:comparison_operator] = secure_params[:comparison_operator].strip.upcase if secure_params[:comparison_operator]
        secure_params
    end
end