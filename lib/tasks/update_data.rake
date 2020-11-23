namespace :update_data do
  desc 'Update type of project and billing frequency column'
  task update_project_fields: :environment do
    projects = Project.where(is_free: true).update_all(type_of_project: 'Free', billing_frequency: 'NA')
    projects = Project.where(is_free: false).update_all(type_of_project: 'T&M', billing_frequency: 'Monthly')
  end

  desc 'Update Leave Type column'
  task update_leave_type_field: :environment do
    LeaveApplication.update_all(leave_type: LeaveApplication::LEAVE)
  end

  desc 'Update employee id to have proper padding of 0'
  task update_employee_id: :environment do
    User.nin('employee_detail.employee_id': [nil, '']).each do |user|
      employee_id = user.employee_detail.employee_id
      updated_employee_id = employee_id.rjust(3, '0')
      if employee_id != updated_employee_id
        puts "Changing employee id of employee.email #{user.email} - changes '#{employee_id}' to '#{updated_employee_id}'"
        user.employee_detail.set(employee_id: updated_employee_id)
      end
    end
  end
end
