class DailyQuoteJob
    def get(quote, range="3mo")
        data = QuoteProvider.provide_for quote, range, "1d"
        QuotePersister.persist data
    end
end