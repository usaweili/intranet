namespace :resigned_employees do
  desc "Reject all leaves of resigned employees"
  task reject_future_leaves: :environment do
    User.where(:status.ne => 'approved').each do |user|
      user.reject_future_leaves
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
