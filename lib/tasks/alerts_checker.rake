desc "Trading alerts checker"
task :alerts_checker => :environment do
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