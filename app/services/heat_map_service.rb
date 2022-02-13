class HeatMapService
    def get(heat_map)
        data = {}

        heat_map.tickers.split(',').each do |ticker|
            data[ticker] = get_stock_performance ticker
        end

        data
    end

    private

    def get_stock_performance(ticker)
        # TODO holidays distorts weeks this way
        # TODO tests

        last_quote = get_last_quote ticker

        return nil unless last_quote

        previous_day_quote = get_past_quote ticker, (last_quote.date - 1.day)
        previous_week_quote = get_past_quote ticker, (last_quote.date - 7.days)
        previous_month_quote = get_past_quote ticker, (last_quote.date - 1.month)
        previous_quarter_quote = get_past_quote ticker, (last_quote.date - 3.months + 2.days) # TODO hack, should understand it

        one_day_performance =
            !previous_day_quote.nil? ? ((last_quote.close - previous_day_quote.close) / previous_day_quote.close * 100) : nil

        one_week_performance =
            !previous_week_quote.nil? ? ((last_quote.close - previous_week_quote.close) / previous_week_quote.close * 100) : nil

        one_month_performance =
            !previous_month_quote.nil? ? ((last_quote.close - previous_month_quote.close) / previous_month_quote.close * 100) : nil

        three_months_performance =
            !previous_quarter_quote.nil? ? ((last_quote.close - previous_quarter_quote.close) / previous_quarter_quote.close * 100) : nil

        {
            "performance" => {
                "1d" => one_day_performance.round(2),
                "1w" => one_week_performance.round(2),
                "1m" => one_month_performance.round(2),
                "3m" => three_months_performance.round(2)
            },
            "price" => last_quote.close.round(2)
        }

    end

    private

    def get_last_quote(ticker)
        StockSnapshot.where(ticker: ticker).order(timestamp: :asc).last
    end

    def get_past_quote(ticker, date)
        StockSnapshot.where("ticker = ? AND date <= ?", ticker, date).order(timestamp: :asc).last
    end
end