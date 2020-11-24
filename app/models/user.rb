class User
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  #model's concern
  include LeaveAvailable
  include UserDetail

  devise :database_authenticatable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:google_oauth2]
  INTERN_ROLE = "Intern"
  ROLES = ['Super Admin', 'Admin', 'Manager', 'HR', 'Employee', INTERN_ROLE, 'Finance', 'Consultant']

  ## Database authenticatable
  field :email,               :type => String, :default => ""
  field :encrypted_password,  :type => String, :default => ""
  field :role,                :type => String, :default => "Employee"
  field :uid,                 :type => String
  field :provider,            :type => String
  field :status,              :type => String, :default => STATUS[0]

  ## Rememberable
  field :remember_created_at, :type => Time
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: String



  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  field :access_token,       :type => String
  field :expires_at,         :type => Integer
  field :refresh_token,      :type => String
  field :visible_on_website, :type => Boolean, :default => false
  field :website_sequence_number, :type => Integer
  field :allow_backdated_timesheet_entry, :type => Boolean, :default => false

  has_many :leave_applications
  has_many :attachments
  has_many :time_sheets
  has_many :user_projects
  has_and_belongs_to_many :schedules
  has_and_belongs_to_many :managed_projects, class_name: 'Project', foreign_key: 'managed_project_ids', inverse_of: :managers

  after_update :delete_team_cache, if: :website_fields_changed?
  before_create :associate_employee_id
  after_update do
    associate_employee_id_if_role_changed
    call_monitor_service if status_changed? && status_was == 'approved' && status == 'pending'
  end

  has_many :entry_passes
  accepts_nested_attributes_for :entry_passes, reject_if: :all_blank, :allow_destroy => true

  accepts_nested_attributes_for :attachments, reject_if: :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :time_sheets, :allow_destroy => true
  accepts_nested_attributes_for :employee_detail
  validates :email, format: {with: /\A.+@#{ORGANIZATION_DOMAIN}/, message: "Only #{ORGANIZATION_NAME} email-id is allowed."}
  validates :role, :email, presence: true
  validates_associated :employee_detail
  scope :project_engineers, ->{where(:role.nin => ['HR','Finance'], :status => STATUS[2]).asc("public_profile.first_name")}
  scope :employees, ->{all.asc("public_profile.first_name")}
  scope :approved, ->{where(status: 'approved')}
  scope :visible_on_website, -> {where(visible_on_website: true)}
  scope :interviewers, ->{where(:role.ne => 'Intern')}
  scope :get_approved_users_to_send_reminder, ->{where('$and' => ['$or' => [{ role: 'Intern' }, { role: 'Employee' }], status: STATUS[2]])}
  scope :management_team, ->{ approved.any_of({role: "HR"},{role: "Manager"},{role: "Admin"}) }
  #Public profile will be nil when admin invite user for sign in with only email address
  delegate :name, to: :public_profile, :allow_nil => true
  delegate :designation, to: :employee_detail, :allow_nil => true
  delegate :mobile_number, to: :public_profile, :allow_nil => true
  delegate :employee_id, to: :employee_detail, :allow_nil => true
  delegate :date_of_joining, to: :private_profile, :allow_nil => true
  delegate :date_of_birth, to: :public_profile, :allow_nil => true
  delegate :date_of_relieving, to: :employee_detail, :allow_nil =>true
  delegate :location, to: :employee_detail, :allow_nil => true

  scope :leaders, ->{ visible_on_website.asc(:website_sequence_number).in(role: ROLE[:admin]) }
  scope :members, ->{ visible_on_website.nin(:role.in => [ ROLE[:admin], ROLE[:consultant] ]).asc(['public_profile.first_name']) }

  before_create do
    self.website_sequence_number = (User.max(:website_sequence_number) || 0) + 1
  end

  before_save do
    assign_leave('Role Updated') if self.role_changed? &&
                                    self.role_was == INTERN_ROLE &&
                                    [ ROLE[:employee], ROLE[:consultant] ].include?(self.role)
  end

  slug :name
  # Hack for Devise as specified in https://github.com/plataformatec/devise/issues/2949#issuecomment-40520236
  def self.serialize_into_session(record)
    [record.id.to_s, record.authenticatable_salt]
  end

  def set_user_project_entries_inactive
    UserProject.where(user_id: self.id, active: true).update_all(active: false, end_date: Date.today)
  end

  def remove_from_manager_ids
    managed_projects.each do |project|
      project.set(manager_ids: project.manager_ids.reject {|manager_id| manager_id == id})
    end
    self.set(managed_project_ids: [])
  end

  def remove_from_notification_emails
    User.where(:'employee_detail.notification_emails'.in => [self.email]).each do |user|
      user.employee_detail.set(notification_emails: user.employee_detail.notification_emails.reject {|email| email == self.email})
    end
  end

  def self.leave_notification_emails(user_ids)
    emails = [
      User.approved.where(role: 'HR').pluck(:email),
      'hr@joshsoftware.com',
      'shailesh.kalekar@joshsoftware.com',
      'sameert@joshsoftware.com',
    ].flatten.compact.uniq

    users = User.where(:id.in => [user_ids].flatten)
    users.each do |user|
      emails += user.get_managers_emails +
       user.employee_detail.try(:get_notification_emails)
    end
    emails.flatten.compact.uniq
  end

  def notification_emails
    [
      User.approved.where(role: 'HR').pluck(:email), User.approved.where(role: 'Admin').first.try(:email),
      self.employee_detail.try(:get_notification_emails).try(:split, ','), self.get_managers_emails
    ].flatten.compact.uniq
  end

  def call_monitor_service
    CodeMonitoringWorker.perform_async({ event_type: 'User Resigned', user_id: id.to_s })
  end

  def sent_mail_for_approval(leave_application_id)
    notified_users = User.leave_notification_emails(self.id)
    UserMailer.delay.leave_application(self.email, notified_users, leave_application_id)
  end

  def role?(role)
    self.role == role
  end

  def can_edit_user?(user)
    (["HR", "Admin", "Finance", "Manager", "Super Admin"].include?(self.role)) || self == user
  end

  def can_download_document?(user, attachment)
    user = user.nil? ? self : user
    (["Admin", "Finance", "Manager", "Super Admin"].include?(self.role)) || attachment.user_id == user.id
  end

  def can_change_role_and_status?(user)
    return true if (["Admin", "Super Admin"]).include?(self.role)
    return true if self.role?("HR") and self != user
    return false
  end

  def is_employee_or_intern?
    [ROLE[:intern], ROLE[:employee]].include?(role)
  end

  def is_consultant?
    self.role == ROLE[:consultant]
  end

  def is_admin_or_hr?
    [ROLE[:HR], ROLE[:admin]].include?(role)
  end

  ["Admin", "Manager"].each do | method |
    define_method "is_#{method.downcase}?" do
      role.eql?(method)
    end
  end

  def is_management?
    [ROLE[:HR], ROLE[:admin], ROLE[:manager]].include?(role)
  end

  def is_approved?
    self.status == 'approved'
  end

  def is_intern?(role)
    [ROLE[:intern]].include?(role)
  end

  def allow_in_listing?
    return true if self.status == 'approved'
    return false
  end

  def set_details(dobj, value)
    unless value.nil?
      set("#{dobj}_day" => value.day)
      set("#{dobj}_month" => value.month)
    end
  end

  def website_fields_changed?
    website_sequence_number_changed? || visible_on_website_changed?
  end

  def generate_errors_message
    error_msg = []
    error_msg.push(errors.full_messages,
                   public_profile.errors.full_messages,
                   private_profile.errors.full_messages,
                   employee_detail.try(:errors).try(:full_messages))
    error_msg.join(' ')
  end

  def reject_future_leaves
    return if self.status == 'approved'
    LeaveApplication.where(:start_at.gte => Date.today, user: self).each do |leave_application|
      leave_application.update(leave_status: 'Rejected')
    end
  end

  def add_or_remove_projects(params)
    return_value_of_add_project = return_value_of_remove_project = true
    existing_project_ids = UserProject.where(user_id: id, end_date: nil).pluck(:project_id)
    existing_project_ids.map!(&:to_s)
    params[:user][:project_ids].shift
    ids_for_add_project = params[:user][:project_ids].present? ? params[:user][:project_ids] - existing_project_ids : []
    ids_for_remove_project = params[:user][:project_ids].present? ? existing_project_ids - params[:user][:project_ids] : existing_project_ids
    return_value_of_add_project = add_projects(ids_for_add_project) if ids_for_add_project.present?
    return_value_of_remove_project = remove_projects(ids_for_remove_project) if ids_for_remove_project.present?
    return return_value_of_add_project, return_value_of_remove_project
  end

  def add_projects(project_ids)
    return_value = true
    project_ids.each do |project_id|
      return_value = UserProject.create!(user_id: id, project_id: project_id, start_date: DateTime.now - 7.days, end_date: nil) rescue false
      if return_value == false
        break
      end
    end
    return_value
  end

  def remove_projects(project_ids)
    return_value = true
    project_ids.each do |project_id|
      user_project = UserProject.where(user_id: id, project_id: project_id, end_date: nil).first
      return_value = user_project.update_attributes!(end_date: DateTime.now) rescue false
      if return_value == false
        break
      end
    end
    return_value
  end

  def get_managers_emails
    manager_ids = projects.pluck(:manager_ids).flatten.uniq
    User.in(id: manager_ids, status: 'approved').collect(&:email)
  end

  def get_managers_emails_for_timesheet
    project_ids = user_projects.where(
      active: true,
      end_date: nil,
      time_sheet: true
    ).pluck(:project_id)
    
    manager_ids = Project.in(id: project_ids).pluck(:manager_ids).flatten.uniq
    User.in(id: manager_ids, status: 'approved').pluck(:email)
  end

  def get_managers_names
    manager_ids = projects.pluck(:manager_ids).flatten.uniq
    User.in(id: manager_ids, status: 'approved').collect(&:name)
  end

  def self.get_hr_emails
    User.approved.where(role: "HR").pluck(:email)
  end

  def project_ids
    project_ids = user_projects.where(active: true, end_date: nil)
                               .pluck(:project_id)
  end

  def project_details
    details = employee_project_details
    manager_projects = managed_projects.where(is_active: true)
    manager_projects.each { |i| details << { id: i.id.to_s, name: i.name }}
    details
  end

  def employee_project_details
    details = []
    project_ids.each do |id|
      project = Project.where(id: id).first
      details << { id: project.id.to_s, name: project.name }
    end
    details
  end

  def worked_on_projects(from_date, to_date)
    project_ids = time_sheets.where(:date.gte => from_date, :date.lte => to_date).pluck(:project_id).uniq
    Project.in(id: project_ids)
  end

  def projects
    project_ids = user_projects.where(active: true, end_date: nil).pluck(:project_id)
    Project.in(id: project_ids)
  end

  def calculate_next_employee_id
    employee_id_array = User.distinct("employee_detail.employee_id")
    employee_id_array.map!(&:to_i)

    if role?(ROLE[:consultant])
      employee_ids = employee_id_array.select{ |id| id > 10000 }
      emp_id = employee_ids.empty? ? 10000 : employee_ids.max
    elsif self.employee_detail.try(:location) == 'Bengaluru'
      employee_ids = employee_id_array.select{ |id| id > 8000 && id < 9000 }
      emp_id = employee_ids.empty? ? 8000 : employee_ids.max
    elsif self.employee_detail.try(:location) == 'Plano'
      usa_employee_ids = employee_id_array.select{ |id| id > 9000 && id < 10000}
      emp_id = usa_employee_ids.empty? ? 9000 : usa_employee_ids.max
    else
      pune_employee_ids = employee_id_array.select { |id| id <= 9000}
      emp_id = pune_employee_ids.empty? ? 0 : pune_employee_ids.max
    end
    emp_id = emp_id + 1
  end

  def associate_employee_id
    return if is_intern?(role)
    emp_id = calculate_next_employee_id

    if self.employee_detail.present?
      self.employee_detail.employee_id = emp_id
    else
      self.employee_detail = EmployeeDetail.new(employee_id: emp_id)
    end
  end

  def associate_employee_id_if_role_changed
    if role_changed?
      if is_intern?(role_was)
        emp_id = calculate_next_employee_id
        self.employee_detail.update_attributes(employee_id: emp_id)
      end
    end
  end

  def experience_as_of_today
    previous_work_experience = private_profile.try(:previous_work_experience)
    if private_profile.try(:date_of_joining).present?
      date_of_joining = private_profile.date_of_joining

      today  = Date.today
      # get number of completed months
      months = (today.year - date_of_joining.year) * 12
      # if current months is not completed then reduce by 1
      months += today.month - date_of_joining.month - (today.day >= date_of_joining.day ? 0 : 1)

      previous_work_experience ? previous_work_experience + months : months
    end
  end

  def self.to_csv(options={})
    column_names = ['name', 'joining date', 'previous work experience(months)',
        'experience as on today(months)', 'designation', 'is_Billable?',
        'technical skills', 'other skills', 'projects']
    CSV.generate(options) do |csv|
      csv << column_names.collect(&:titleize)
      all.map do |user|
        tech_skills = user.public_profile.technical_skills.join(', ') if user.public_profile.technical_skills.present?
        csv << [
          user.public_profile.name,
          user.private_profile.try(:date_of_joining),
          user.private_profile.try(:previous_work_experience),
          user.try(:experience_as_of_today),
          user.employee_detail.designation.try(:name),
          user.employee_detail.is_billable? ? 'Yes' : 'No',
          tech_skills,
          user.public_profile.skills,
          user.projects.collect(&:name).join(', ')
        ]
      end
    end
  end

  def get_user_projects_from_user(project_id, from_date, to_date)
    user_projects.where("$and"=>[
        {
          "$or" => [
            {
              "$and" => [
                {
                  :start_date.lte => from_date
                },
                {
                  end_date: nil
                }
              ]
            },
            {
              "$and" => [
                {
                  :start_date.gte => from_date
                },
                {
                  :end_date.lte => to_date
                }
              ]
            },
            {
              "$and" => [
                {
                  :start_date.lte => from_date
                },
                {
                  :end_date.lte => to_date
                },
                {
                  :end_date.gte => from_date
                }
              ]
            },
            {
              "$and" => [
                {
                  :start_date.gte => from_date
                },
                {
                  :end_date.gte => to_date
                },
                {
                  :start_date.lte => to_date
                }
              ]
            },
            {
              "$and" => [
                {
                  :start_date.gte => from_date
                },
                {
                  end_date: nil
                },
                {
                  :start_date.lte => to_date
                }
              ]
            },
            {
              "$and" => [
                {
                  :start_date.lte => from_date
                },
                {
                  :end_date.gte => to_date
                }
              ]
            }
          ]
        },
        {
          project_id: project_id
        }
      ])
  end
end
