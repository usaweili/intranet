class TimesheetRemainderMailer < ActionMailer::Base
  default :from => 'intranet@joshsoftware.com',
          :reply_to => 'hr@joshsoftware.com'
  
  def send_timesheet_reminder_mail(user, slack_id, text)
    managers_emails = []
    @user = user
    @text = text
    managers_emails = @user.get_managers_emails
    mail(subject: 'Timesheet Reminder', to: user.email, cc: managers_emails + DEFAULT_TIMESHEET_MANAGERS + ['hr@joshsoftware.com'])
  end

  def user_timesheet_for_diffrent_project(user, timesheets)
    managers_emails = []
    @user           = user
    managers_emails = @user.get_managers_emails
    hr_emails       = User.get_hr_emails
    @timesheets     = timesheets
    mail( 
      subject: 'Timesheet for project(s) which are not yet assigned',
      to: user.email,
      cc: managers_emails + hr_emails
    )
    
  end
end
