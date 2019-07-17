namespace :user_without_timesheet do
  desc "send weekly report to HR"
  task weekly_report: :environment do
    from_date = Date.today - 7
    to_date   = Date.today - 3
    TimeSheet.get_users_who_not_filled_timesheet(from_date, to_date)
  end

  desc "send monthly report to HR"
  task monthly_report: :environment do
    from_date = (Date.today - 1).beginning_of_month
    to_date   = Date.today - 1
    TimeSheet.get_users_who_not_filled_timesheet(from_date, to_date)
  end
end
