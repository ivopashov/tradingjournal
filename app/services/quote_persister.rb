class QuotePersister
    def self.persist(data)
        return unless data
        return if data['chart']['result'].nil?

        ticker = data['chart']['result'].first['meta']['symbol']

        data['chart']['result'].first['timestamp'].each_with_index do |timestamp, index|
            time_at_timestamp_utc = Time.at(timestamp).utc

            volume = data['chart']['result'].first['indicators']['quote'].first['volume'][index]
            close = data['chart']['result'].first['indicators']['quote'].first['close'][index] # TODO adjclose? splits?
            open = data['chart']['result'].first['indicators']['quote'].first['open'][index]
            high = data['chart']['result'].first['indicators']['quote'].first['high'][index]
            low = data['chart']['result'].first['indicators']['quote'].first['low'][index]

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