desc "Fetch quotes"
task :daily_quotes => :environment do
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
