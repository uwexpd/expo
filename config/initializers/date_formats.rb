my_formats = {
  :date_time12            => "%m/%d/%Y %I:%M%p",
  :date_time24            => "%m/%d/%Y %H:%M",
  :date_with_day_of_week  => "%A, %B %d, %Y",
  :date_with_full_month   => "%B %d, %Y",
  :time12                 => "%l:%M %p",
  :time_with_seconds      => "%H:%M:%S",
  :date_at_time12         => "%A, %B %d, %Y at %I:%M",
  :date_by_time12         => "%A, %B %d, %Y by %I:%M",
  :date_at_time24         => "%A, %B %d, %Y at %H:%M",
  :date_by_time24         => "%A, %B %d, %Y by %H:%M"
  
}

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(my_formats)
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(my_formats)