require 'rest-client'

class QuoteProvider
    def self.provide_for(ticker, range="3mo", interval='1d')
      begin
        allowed_ranges = ["1d", "5d", "1mo", "3mo", "6mo"]
        allowed_intervals = ["1m", "5m", "1h", "1d"]

        unless range.in? allowed_ranges
            raise ArgumentError.new "Allowed ranges are 1d, 5d, 1mo, 3mo and 6mo"
        end

        unless interval.in? allowed_intervals
            raise ArgumentError.new "Allowed intervals are 1m, 5m, 1h and 1d"
        end

        url = "https://query1.finance.yahoo.com/v7/finance/chart/#{ticker}?range=#{range}&interval=#{interval}&indicators=quote&includeTimestamps=true&includePrePost=false&corsDomain=finance.yahoo.com"
        p "Requesting #{url}"
        JSON.parse RestClient.get url
      rescue => e
        # TODO retry transient failures, what types are they, retry keyword
        p e.message
        p url
        return nil
      end
    end
end