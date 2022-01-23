require 'rufus-scheduler'
require 'rake'

scheduler = Rufus::Scheduler.singleton

scheduler.every '1m' do
    p "#{Time.now} Running daily quotes"
    DailyQuotes.delay.run
    unless MarketsOpeningHours.open?
        p "#{Time.now} Skip DailyQuotes as it is weekend or holiday"
        next
    end

    if MarketsOpeningHours.are_markets_regular_opening_hours_now? || MarketsOpeningHours.within_thirty_minutes_after_regular_hours_end?
        p "#{Time.now} Running daily quotes"
        DailyQuotes.delay.run
    else
        p "#{Time.now} Skip DailyQuotes as markets are closed"
    end
end

scheduler.every '1m 30s' do
    unless MarketsOpeningHours.open?
        p "#{Time.now} Skip trading alerts checking as it is weekend or holiday"
        next
    end

    if MarketsOpeningHours.are_markets_regular_opening_hours_now? || MarketsOpeningHours.within_thirty_minutes_after_regular_hours_end?
        p "#{Time.now} Checking trading alerts"
        TradingAlertsChecker.delay.run
    else
        p "#{Time.now} Skip trading alerts as markets are closed"
    end
end

scheduler.every '1h' do
    p "#{Time.now} running StockSnapshotJanitor"
    StockSnapshotJanitor.delay.run
end