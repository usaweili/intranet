module ApplicationHelper
  
  def flash_class(type)
    case type
    when 'notice' then "alert alert-info"
    when 'success' then "alert alert-success" 
    when 'error' then "alert alert-error"
    when 'alert' then "alert alert-error"
    end
  end

  def git_branch
    if Rails.env.staging?
      `head -n1 #{Rails.root + 'branch_deployed.txt'}`
    else
      `git symbolic-ref --short HEAD`
    end.chomp
  end
  
  def set_label status
    status ? 'label-success' : 'label-warning'
  end

  def can_access?(event)
    role = current_user.role
    case event
    when 'Events' then ['Consultant'].include?(role)
    when 'Newsletter' then ['HR', 'Admin', 'Super Admin'].include?(role)
    when 'Contacts' then ['Admin', 'Super Admin'].include?(role)
    when 'Manage Leave' then ['Admin', 'Super Admin', 'HR'].include?(role)
    when 'Assessments' then ['Consultant'].include?(role)
    when 'Repositories' then ['Admin', 'Manager', 'Employee', 'Intern'].include?(role)
    end
  end
end
