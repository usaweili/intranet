class ProjectMailer < ActionMailer::Base
  default :from => 'intranet@joshsoftware.com',
          :reply_to => 'hr@joshsoftware.com'

  def send_project_team_report(username, user_email)
    csv = Project.team_data_to_csv
    @username = username
    attachments["user_project_data_#{Date.today.strftime("%d%b%y")}.csv"] = csv
    mail(subject: 'Project Team Data Report', to: user_email)
  end
end
