class TimesheetRemainderMailer < ActionMailer::Base
  default :from => 'intranet@joshsoftware.com',
          :reply_to => 'hr@joshsoftware.com'
  
  def send_timesheet_reminder_mail(user, slack_id, text)
    managers_emails = []
    @user = user
    @text = text
    managers_emails = @user.get_managers_emails
    mail(subject: 'Timesheet Reminder', to: user.email, cc: managers_emails + DEFAULT_TIMESHEET_MANAGERS)
  end

  def user_timesheet_for_diffrent_project(user, timesheet, project_name)
    managers_emails = []
    @user           = user
    managers_emails = @user.get_managers_emails
    hr_emails       = User.get_hr_emails
    @timesheet      = timesheet
    @project_name   = project_name
    mail( 
      subject: 'Timesheet for project which is not assigned to you',
      to: user.email,
      cc: managers_emails + hr_emails
    )
    
  end
end
