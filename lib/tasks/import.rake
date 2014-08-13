require 'csv'

desc "Import users from csv file"
task :import => [:environment] do

  file = "public/test.csv"

  CSV.foreach(file, :headers => true) do |row|
    user = Light::User.create(
      email_id: row[3].strip,
      username: row[1] + " " + row[2],
      is_subscribed: row[5],
      joined_on: row[6],
      source: "old data"
    )
    
    p user.email_id unless user.valid?
  end
end

