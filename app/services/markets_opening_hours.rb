class MarketsOpeningHours
    def self.open?
        return false if today_is_weekend?
        return false if today_is_a_holiday_for_markets?

        true
    end

    def self.within_thirty_minutes_after_regular_hours_end?
        return false if today_is_weekend?
        return false if today_is_a_holiday_for_markets?

        eastern_time_now = Time.new.utc.in_time_zone "Eastern Time (US & Canada)"

        eastern_time_now.hour == 16 && eastern_time_now.min <= 30
    end

    def self.are_markets_regular_opening_hours_now?
        # on Friday, Nov. 25, 2022 markets close early at 1 pm vs 4 but that is ok
        # not to handle this corner case here

        eastern_time_now = Time.new.utc.in_time_zone "Eastern Time (US & Canada)"

        is_time_within_regular_opening_hours? eastern_time_now
    end

    def self.is_time_within_regular_opening_hours?(time_with_time_zone)
        return false if time_with_time_zone.hour >= 16 || time_with_time_zone.hour <= 8
        return false if time_with_time_zone.hour == 9 && time_with_time_zone.min < 30

        true
    end

    private

    def self.today_is_a_holiday_for_markets?
        market_holidays = [
            Date.new(2022, 1, 17), # Martin Luther King Jr. Day
            Date.new(2022, 2, 21), # Presidents' Day/Washington's Birthday
            Date.new(2022, 4, 15), # Good Friday and my bday!
            Date.new(2022, 5, 30), # Memorial Day
            Date.new(2022, 6, 20), # Juneteenth National Independence Day (Observed)
            Date.new(2022, 7, 4), # Independence Day
            Date.new(2022, 9, 5), # Labor Day
            Date.new(2022, 11, 24), # Thanksgiving Day
            Date.new(2022, 12, 26) # Christmas Day (Observed)
        ]

        Date.today.in? market_holidays
    end

    def self.today_is_weekend?
        Date.today.saturday? || Date.today.sunday?
    end
end