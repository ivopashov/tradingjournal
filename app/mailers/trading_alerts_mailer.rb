class TradingAlertsMailer < ApplicationMailer
    def new_trading_alerts_email
        @trading_alert = params[:trading_alert]
        mail(to: @trading_alert.user.email, subject: "Trading alert triggered!")
    end
end
