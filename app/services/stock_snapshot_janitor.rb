class StockSnapshotJanitor
    def self.run
        tickers = (HeatMap.pluck(:tickers).map { |t| t.split(",") }.flatten + TradingAlert.pluck(:ticker)).uniq

        StockSnapshot.where.not(ticker: tickers).delete_all
    end
end