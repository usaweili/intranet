namespace :user_name do
  desc "strip leading or trailing whitespaces from the user names"
  task :strip_user_name => :environment do
    User.all.each do |user|
      first_name = user.public_profile.first_name.strip
      last_name = user.public_profile.last_name.strip
      if user.public_profile.first_name != first_name || user.public_profile.last_name != last_name
        puts "Changing name of user.email #{user.email} - changes '#{first_name}' '#{last_name}'"
        user.public_profile.update(first_name: first_name, last_name: last_name)
      end
    end
  end
end
