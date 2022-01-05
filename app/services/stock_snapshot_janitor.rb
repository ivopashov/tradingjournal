class StockSnapshotJanitor
    def self.run
        tickers = (HeatMap.pluck(:tickers).map { |t| t.split(",") }.flatten + PriceAlert.pluck(:ticker)).uniq

        StockSnapshot.where.not(ticker: tickers).delete_all
    end
end