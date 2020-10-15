require 'time_difference'
namespace :timesheet_reminder do
  desc "Reminds to employee to fill timesheet"
  task :ts_reminders => :environment do
    unless HolidayList.is_holiday?(Date.today, "India")
      @time_sheet = TimeSheet.new
      users = User.get_approved_users_to_send_reminder.indian
      TimeSheet.search_user_and_send_reminder(users)
    end
    unless HolidayList.is_holiday?(Date.today, "USA")
      @time_sheet = TimeSheet.new
      users = User.get_approved_users_to_send_reminder.american
      TimeSheet.search_user_and_send_reminder(users)
    end
  end

  desc "Reminds if user has filled timesheet for project which is not assigned to him"
  task :timesheet_for_different_project => :environment do
    TimeSheet.get_users_and_timesheet_who_have_filled_timesheet_for_different_project
  end
end
