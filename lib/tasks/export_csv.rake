require 'csv'
namespace :export_csv do
  desc "Export work experience in csv for changing into month"
  task :export_work_experience => :environment do
    file    = "#{Rails.root}/public/user_work_experience.csv"
    headers = ["user_id", "Name", "Email", "work_experience"]
    CSV.open(file, 'w', write_headers: true, headers: headers) do | writer |
      User.employees.each do| user |
        writer << [user.id, user.public_profile.try(:name), user.email, user.private_profile.try(:work_experience)]
      end
    end
  end

  desc "Import csv and update work_experience of users"
  task :import_work_experience => :environment do
    file    = "#{Rails.root}/public/user_work_experience.csv"
    headers = ['user_id', 'Name', 'Email', 'work_experience(In years)', 'work_experience(In months)']
    csv  = CSV.read(file, skip_blanks: true, headers: true)
    CSV.open(file, 'w', write_headers: true, headers: headers) do | writer |
      csv.each do| row |
        user            = User.find_by(id: row['user_id'])
        work_experience = (row['work_experience'].to_f * 12).to_i
        writer << [row['user_id'], row['Name'], row['Email'], row['work_experience'], work_experience]
        #user.private_profile.present? ?
        #user.private_profile.update(previous_work_experience: work_experience) : next
      end
    end
  end
end
