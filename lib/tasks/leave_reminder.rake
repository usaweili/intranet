namespace :leave_reminder do
  desc 'Remainds admin and HR who are on leave tomorrow.'
  task daily: :environment do
    Rails.logger.info('in rake task')
    COUNTRIES.each do |country|
      user_ids = User.get_employees(country).pluck(:id)
      unless HolidayList.is_holiday?(Date.today, country)
        next_working_day = HolidayList.next_working_day(Date.today, country) 
        leave_applications = LeaveApplication.get_leaves_for_sending_reminder(next_working_day, user_ids)
        UserMailer.delay.leaves_reminder(leave_applications.to_a)
      end
    end
  end

  desc 'Reminds managers and HR whose leave beginning in next two days and leave is pending.'
  task :pending_leave => :environment do
    COUNTRIES.each do |country|
      user_ids = User.get_employees(country).pluck(:id)
      unless HolidayList.is_holiday?(Date.today, country)
        LeaveApplication.pending_leaves_reminder(country, user_ids)
      end
    end
  end
end
