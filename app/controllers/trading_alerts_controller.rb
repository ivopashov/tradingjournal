class TradingAlertsController < ApplicationController
    def index
        @active_trading_alerts = TradingAlert.where user_id: current_user.id, triggered: false
        @recently_triggered_trading_alerts = TradingAlert.where user_id: current_user.id, triggered: true, triggered_on: (10.days.ago..Time.now)
    end

    def new
        @trading_alert = TradingAlert.new
    end

    def create
        @trading_alert = TradingAlert.new trading_alert_params.merge(user_id: current_user.id)

        if @trading_alert.save
            DailyQuotes.delay.backfill [trading_alert_params['ticker'].upcase]
            redirect_to action: :index
        else
            render :new, trading_alert: @trading_alert
        end
    end

    def destroy
        @trading_alert = TradingAlert.find params["id"]
        @trading_alert.destroy

        flash.notice = "Trading alert '#{@trading_alert.ticker} - #{@trading_alert.rule}' was deleted"

        redirect_to action: :index
    end

    private

    def trading_alert_params
        secure_params = params.require(:trading_alert).permit(:ticker, :rule)
        secure_params[:rule] = secure_params[:rule].strip if secure_params[:rule]
        secure_params[:ticker] = secure_params[:ticker].strip.upcase if secure_params[:ticker]
        secure_params
    end
end