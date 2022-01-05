require 'rufus-scheduler'
require 'rake'

scheduler = Rufus::Scheduler.singleton

scheduler.every '1m' do
    unless MarketsOpeningHours.open?
        p "Skip DailyQuotes as it is weekend or holiday"
        return
    end

    if MarketsOpeningHours.are_markets_regular_opening_hours_now? || MarketsOpeningHours.within_thirty_minutes_after_regular_hours_end?
        p "Running daily quotes"
        DailyQuotes.delay.run
    else
        p "Skip DailyQuotes as markets are closed"
    end
end

scheduler.every '1m 30s' do
    unless MarketsOpeningHours.open?
        p "Skip price alerts checking as it is weekend or holiday"
        return
    end

    if MarketsOpeningHours.are_markets_regular_opening_hours_now? || MarketsOpeningHours.within_thirty_minutes_after_regular_hours_end?
        p "Checking price alerts"
        PriceAlertsChecker.delay.run
    else
        p "Skip price alerts as markets are closed"
    end
end

scheduler.every '1h' do
    StockSnapshotJanitor.delay.run
end