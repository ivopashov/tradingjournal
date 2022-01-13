class QuotePersister
    def self.persist(data)
        return unless data
        return if data['chart']&.[]('result').nil?

        first_result = ticker = data['chart']['result'].first
        return if first_result.nil?
        return if first_result['meta']&.[]('symbol').nil?
        return if first_result['timestamp'].nil?

        ticker = first_result['meta']['symbol']

        first_result['timestamp'].each_with_index do |timestamp, index|
            time_at_timestamp_utc = Time.at(timestamp).utc

            volume = first_result['indicators']['quote'].first['volume'][index]
            close = first_result['indicators']['quote'].first['close'][index] # TODO adjclose? splits?
            open = first_result['indicators']['quote'].first['open'][index]
            high = first_result['indicators']['quote'].first['high'][index]
            low = first_result['indicators']['quote'].first['low'][index]

            stock_snapshot = StockSnapshot.where(ticker: ticker, date: time_at_timestamp_utc.to_date).first

            unless stock_snapshot
                StockSnapshot.create! ticker: ticker, timestamp: time_at_timestamp_utc, date: time_at_timestamp_utc.to_date, close: close, volume: volume, open: open, high: high, low: low
                next
            end

            if MarketsOpeningHours.is_time_within_regular_opening_hours?(time_at_timestamp_utc.in_time_zone("Eastern Time (US & Canada)"))
                stock_snapshot.update! close: close, volume: volume, open: open, high: high, low: low, timestamp: time_at_timestamp_utc
            end
        end
    end
end