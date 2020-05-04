namespace :leave_reminder do
  desc "Remainds admin and HR who are on leave tomorrow."
  task daily: :environment do
    Rails.logger.info("in rake task")
    unless HolidayList.is_holiday?(Date.today, "India")
      next_working_day = HolidayList.next_working_day(Date.today, "India") 
      leave_applications = LeaveApplication.get_leaves_for_sending_reminder(next_working_day)
      UserMailer.delay.leaves_reminder(leave_applications.to_a)
    end
    unless HolidayList.is_holiday?(Date.today, "USA")
      next_working_day = HolidayList.next_working_day(Date.today, "USA") 
      leave_applications = LeaveApplication.get_leaves_for_sending_reminder(next_working_day)
      UserMailer.delay.leaves_reminder(leave_applications.to_a)
    end
  end

  desc "Reminds managers and HR whose leave beginning in next two days and leave is pending"
  task :pending_leave => :environment do
    unless HolidayList.is_holiday?(Date.today, "India")
      LeaveApplication.pending_leaves_reminder("India")
    end
    unless HolidayList.is_holiday?(Date.today, "USA")
      LeaveApplication.pending_leaves_reminder("USA")
    end
  end
end
