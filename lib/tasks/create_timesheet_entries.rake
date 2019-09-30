namespace :create_timesheet_entries do

  desc "Read csv and create timesheet entries"
  
  task :create_timesheet => :environment do
    file = "#{Rails.root}/public/timesheet.csv"
    ProcessTimesheetFile.new.process_file_and_create_timesheet(file)
  end
end
