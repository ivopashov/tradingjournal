# Preview all emails at http://localhost:3000/rails/mailers/trading_alerts_mailer
class TradingAlertsMailerPreview < ActionMailer::Preview
    def new_trading_alerts_email
        user = User.new email: "ivo.pashoff@gmail.com"
        trading_alert = TradingAlert.new ticker: "AAPL", rule: "price > 100", triggered: true, triggered_on: Time.now.utc, last_evaluated_on: Time.now.utc, user: user

        TradingAlertsMailer.with(trading_alert: trading_alert).new_trading_alerts_email
    end
end
