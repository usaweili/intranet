class WeeklyTimesheetReportMailer < ActionMailer::Base
  default :from => 'intranet@joshsoftware.com',
          :reply_to => 'hr@joshsoftware.com'
  
  def send_weekly_timesheet_report(csv, email, unfilled_time_sheet_report)
    @unfilled_time_sheet_report = unfilled_time_sheet_report
    attachments["weekly_timesheet_report_#{Date.today}.csv"] = csv
    emails = ([email] + DEFAULT_TIMESHEET_MANAGERS).uniq
    mail(subject: 'Weekly timesheet report', to: emails)
  end

  def send_report_who_havent_filled_timesheet( options = {} )
    @text = options[:text]
    attachments["Employees- Not Filled Timesheet.csv"] = options[:csv]
    mail(
      subject:"Employees List-  who haven't filled timesheet between #{options[:from_date]} to #{options[:to_date]} ",
      to: options[:emails]
    )
  end

end
