class DailyQuotes
    def self.run(tickers=nil)

        if tickers.nil? || tickers.empty?
            tickers = (HeatMap.pluck(:tickers).map { |t| t.split(",") }.flatten + PriceAlert.pluck(:ticker)).uniq
        end

        tickers.each do |ticker|
            DailyQuoteJob.new.get ticker, "5d"
        end
    end

    def self.backfill(tickers)
        tickers.each do |ticker|
            DailyQuoteJob.new.get ticker, "3mo"
        end
    end
end