desc "Send weekend and hoilday's timesheet report to Admin and HR"
task :weekend_timesheet_report => :environment do
  holiday_list = []
  start_date = Date.today - 14
  end_date = Date.today - 1

  start_date.upto(end_date) do |date|
    holiday_list <<  {date: date, country: 'India'} if HolidayList.is_holiday?(date, 'India') # Indian Holidays
    holiday_list <<  {date: date, country: 'USA'} if HolidayList.is_holiday?(date, 'USA')     # USA Holidays
  end

  TimeSheet.generate_and_send_weekend_report(holiday_list, start_date)
end
