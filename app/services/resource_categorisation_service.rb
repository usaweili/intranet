class ResourceCategorisationService
  def initialize(emails)
    @emails = emails
    @headers = ['Employee Name', 'Total Allocation']
  end

  def call
    files = {
      billable_resources: billable.values,
      non_billable_resources: non_billable.values,
      investment_resources: investment.values,
      free_resources: free_project.values,
      bench_resources: bench
    }
    ReportMailer.send_resource_categorisation_report(files, @emails).deliver_now
  end

  def billable
    user_project_ids = []
    projects = Project.where(:type_of_project.in => ['T&M', 'Fixbid'], is_active: true)
    user_project_ids = UserProject.where(
      :project_id.in => projects.pluck(:id),
      active: true,
      billable: true,
      :allocation.gt => 1
    ).pluck(:id)
    get_users(user_project_ids)
  end

  def non_billable
    user_project_ids = []
    projects = Project.where(:type_of_project.in => ['T&M', 'Fixbid'], is_active: true)
    user_project_ids = UserProject.where(
      :project_id.in => projects.pluck(:id),
      active: true,
      billable: false,
      :allocation.lte => 1
    ).pluck(:id)
    get_users(user_project_ids)
  end

  def investment
    user_project_ids = []
    projects = Project.where(type_of_project: 'Investment', is_active: true, is_activity: false)
    user_project_ids = UserProject.where(
      :project_id.in => projects.pluck(:id),
      active: true
    ).pluck(:id)
    get_users(user_project_ids)
  end

  def free_project
    user_project_ids = []
    projects = Project.where(type_of_project: 'Free', is_active: true)
    user_project_ids = UserProject.where(
      :project_id.in => projects.pluck(:id),
      active: true
    ).pluck(:id)
    get_users(user_project_ids)
  end

  def bench
    bench_users = []
    exclude_designations = [
      'Assistant Vice President - Sales',
      'Business Development Executive',
      'Office Assistant'
    ]
    users = User.approved.where(:role.in => ['Intern', 'Employee'])
    users.each do |user|
      unless exclude_designations.include?(user.designation.try(:name))
        active_project_count = UserProject.where(user_id: user.id, active: true).count
        bench_users << { name: user.name } unless active_project_count > 0
      end
    end
    bench_users
  end

  def active_user_ids
    @active_user_ids ||= User.approved.pluck(:id)
  end

  def get_users(user_project_ids)
    users = {}
    user_project_ids.each do |user_project_id|
      user_project = UserProject.where(id: user_project_id).first
      if active_user_ids.include?(user_project.user_id)
        user_id = user_project.user_id.to_s
        if users[user_id].present? && users[user_id][:allocation].present?
          users[user_id][:allocation] += user_project.allocation
        else
          users[user_id] = {
            name: user_project.user.name,
            allocation: user_project.allocation
          }
        end
      end
    end

    users.sort_by{|k, v| v[:name]}.to_h
  end
end
