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
end
