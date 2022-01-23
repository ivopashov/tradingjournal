class TradingAlertsChecker
    def self.run
        trading_alerts = TradingAlert.where triggered: false

        if trading_alerts.empty?
            p "No active trading alerts present"
            return
        end

        unique_tickers = trading_alerts.pluck(:ticker).uniq

        last_stock_snapshots = {};

        unique_tickers.each do |ticker|
            stock_snapshot = StockSnapshot.where(ticker: ticker).order(timestamp: :desc).first
            if stock_snapshot
                last_stock_snapshots[ticker] = stock_snapshot
            else
                p "Can't find stock_snapshot for ticker #{ticker}"
            end
        end

        trading_alerts.each do |alert|
            stock_snapshot = last_stock_snapshots[alert.ticker]

            if stock_snapshot.nil?
                p "No price snapshot for alert #{alert.ticker} with rule: #{alert.rule}"
                next
            end

            should_trigger =
                begin
                    rule = alert.rule.gsub "price", stock_snapshot.close.to_s
                    eval rule
                rescue => e
                    p e
                    false
                end

            if should_trigger
                p "Triggering alert for #{alert.ticker} with rule #{alert.rule}"
                alert.update triggered: true, triggered_on: Time.now.utc, price: stock_snapshot.close
                TradingAlertsMailer.with(trading_alert: alert).new_trading_alerts_email.deliver_now
            else
                p "Alert for #{alert.ticker} with rule #{alert.rule} was not triggered"
            end

            alert.update last_evaluated_on: Time.now.utc
        end
    end
end