desc "Instanciate Weekly Project Summary Email notifiaction"
task :weekly_project_summary => :environment do
  projects = Project.all
  weeks = 4 # Number of weeks we want to add in Notification Email.
  projects.each do |project|
    if project.repositories.count > 0
      manager_emails = project.managers.pluck(:email)
      project.repositories.each do |repo|
        data = repo.code_climate_statistics.order("created_at desc").limit(weeks).reverse
        if data.length > 0 && !manager_emails.empty?
          ProjectMailer.delay.send_weekly_project_summary(project.name, manager_emails, data)
        end
      end
    end
  end
end
