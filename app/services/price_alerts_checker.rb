class PriceAlertsChecker
    def self.run
        price_alerts = PriceAlert.where triggered: false

        if price_alerts.empty?
            p "No active price alerts present"
            return
        end

        unique_tickers = price_alerts.pluck(:ticker).uniq

        last_stock_snapshots = {};

        unique_tickers.each do |ticker|
            stock_snapshot = StockSnapshot.where(ticker: ticker).order(timestamp: :desc).first
            if stock_snapshot
                last_stock_snapshots[ticker] = stock_snapshot
            else
                p "Can't find stock_snapshot for ticker #{ticker}"
            end
        end

        price_alerts.each do |alert|
            stock_snapshot = last_stock_snapshots[alert.ticker]

            if stock_snapshot.nil?
                p "No price snapshot for alert #{alert.name} with ticker: #{alert.ticker}"
                next
            end

            should_trigger = false

            if alert.comparison_operator == ">" || alert.comparison_operator == ">="
                if stock_snapshot.high >= alert.price
                    should_trigger = true
                end
            end

            if alert.comparison_operator == "<" || alert.comparison_operator == "<="
                if stock_snapshot.low <= alert.price
                    should_trigger = true
                end
            end

            if should_trigger
                p "Triggering alert #{alert.name} with ticker #{alert.ticker}"
                alert.update triggered: true, triggered_on: Time.now.utc
            else
                p "Alert #{alert.name} with ticker #{alert.ticker} was not triggered"
            end
        end
    end
end