namespace :resigned_employees do
  desc "Reject all leaves of resigned employees"
  task reject_future_leaves: :environment do
    User.where(:status.ne => 'approved').each do |user|
      user.reject_future_leaves
      p user.email
    end
  end

  desc "Remove resigned employees from notification emails, UserProject and manager_ids of Project"
  task remove_from_project_records_and_notification_emails: :environment do
    User.where(status: "pending").each do |user|
      user.set_user_project_entries_inactive
      user.remove_from_manager_ids
      user.remove_from_notification_emails
      p user.email
    end
  end

  desc "Change status of resigned employees from pending to resigned"
  task change_status_of_resigned_employees: :environment do
    email_ids = []
    User.where(:email.in => email_ids).each do |user|
      user.update(status: 'resigned')
    end
  end
end
