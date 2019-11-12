class ProcessTimesheetFile
  def process_file_and_create_timesheet(file)
    headers = ['Email', 'Project', 'Date', 'Start Time', 'End Time', 'Description', 'Status']
    csv     =  CSV.read(file, headers: true)
    status_file = "#{Rails.root}/public/timsheet_status.csv"
    CSV.open(status_file, 'w', write_headers: true, headers: headers) do | writer |
      csv.each do |row|
        if row['Email'].present?
          error = check_validations(row)
          if error.present?
            writer << [row['Email'], row['Project'], row['Date'], row['Start Time'],
            row['End Time'], row['Description'], error]
          else
            create_timesheet(row)
            status = "Timesheet insert successfully"
            writer << [row['Email'], row['Project'], row['Date'], row['Start Time'],
            row['End Time'], row['Description'], status]
          end
        end
      end
    end
  end

  def create_timesheet(row)
    project   = Project.find_by(name: row['Project']) 
    user      = User.find_by(email: row['Email']) 
    timesheet = TimeSheet.new(user_id: user.id, project_id: project.id, date: row['Date'],
      from_time: row['Start Time'], to_time: row['End Time'],
      description: row['Description'])
    timesheet.save(validate: false)
  end
    

  def check_validations(timesheet_data)
    if user_exists?(timesheet_data['Email'])
      user = User.find_by(email: timesheet_data['Email'])
      if project_exists?(timesheet_data['Project'])
        if timesheet_exists?(timesheet_data, user)
          if timesheet_overlapping?(timesheet_data['Date'], timesheet_data['Start Time'],
            timesheet_data['End Time'], user)
            return 'Timesheet duration overlapping.'
          else
            return nil  
          end
        else
          return 'Timesheet record already Exists'
        end
      else
        return "Project Not Found.Please check project name"
      end 
    else
      return "User with provided Email ID not found"
    end
  end

  def user_exists?(email)
    User.where(email: email).exists?
  end

  def project_exists?(project)
    Project.where(name: project).exists?
  end

  def timesheet_exists?(timesheet_data, user)
    !(TimeSheet.where(date: timesheet_data['Date'], user_id: user.id, from_time: timesheet_data['Start Time'],
      to_time: timesheet_data['End Time']).exists?)
  end

  def timesheet_overlapping?(date, from_time, to_time, user)
    return_value = false
    from_time    = from_time.to_time
    to_time      = to_time.to_time
    TimeSheet.where(date: date, user_id: user.id).order("from_time ASC").each do |time_sheet|
      if time_sheet.from_time < from_time && time_sheet.to_time > to_time ||
       time_sheet.from_time > from_time && time_sheet.to_time < to_time ||
       time_sheet.from_time > from_time && time_sheet.to_time > to_time && time_sheet.from_time < to_time ||
       time_sheet.from_time < from_time && time_sheet.to_time < to_time && time_sheet.to_time > from_time
        return_value = true
        break
      end
    end
    return_value
  end
end
