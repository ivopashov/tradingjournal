class StockSnapshotJanitor
    def self.run
        tickers = HeatMap.pluck(:tickers).map { |t| t.split(",") }.flatten.uniq

        StockSnapshot.where.not(ticker: tickers).delete_all
    end
end