class PublicProfile
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include  UserDetail

  mount_uploader :image, FileUploader

  MAX_CORE_SKILL_COUNT = 3

  field :first_name, default: ''
  field :last_name, default: ''
  field :gender
  field :mobile_number
  field :blood_group
  field :date_of_birth, type: Date
  field :skills
  field :technical_skills, type: Array
  field :skype_id
  field :pivotal_tracker_id
  field :github_handle
  field :twitter_handle
  field :blog_url
  field :image
  field :linkedin_url
  field :facebook_url
  field :slack_handle
  field :gitlab_handle
  field :bitbucket_handle

  #validates_attachment :photo, :content_type => { :content_type => "image/jpg" }

  embedded_in :user

  #validates_presence_of :first_name, :last_name, :gender, :mobile_number, :date_of_birth, :blood_group, :on => :update
  validates :technical_skills, length: { maximum: 3 , message: 'Atmost 3 core skills can be selected'}
  validates :gender, inclusion: { in: GENDER }, allow_blank: true, on: :update
  validates :blood_group, inclusion: { in: BLOOD_GROUPS }, allow_blank: true, on: :update
  validates_format_of [:github_handle, :twitter_handle], without: URI.regexp(['http', 'https']), allow_blank: true
  validates_format_of [:facebook_url, :linkedin_url], with: URI.regexp(['http', 'https']), allow_blank: true

  before_save do
    #We need to manually set the slug because user does not have field 'name' in its model and delegated to public_profile
    user.set_slug
    self.user.set_details("dob", self.date_of_birth) if self.date_of_birth_changed? #set the dob_day and dob_month
    call_monitor_service if (changes.keys & ['github_handle', 'gitlab_handle', 'bitbucket_handle']).length > 0
  end

  # after_update :delete_team_cache, :send_email_to_hr, if: Proc.new{ updated_at_changed? && !slack_handle_changed? }

  def call_monitor_service
    CodeMonitoringWorker.perform_async(monitor_service_params)
  end

  def monitor_service_params
    {
      event_type:             'User Updated',
      user_id:                user.id.to_s,
      public_profile_details: self.as_json(public_profile_fields)
    }
  end

  def public_profile_fields
    {
      only: [:gitlab_handle, :bitbucket_handle, :github_handle]
    }
  end

  def name
    "#{first_name} #{last_name}"
  end

  def image_medium_url
    image.medium.try(:url) unless image.try(:url) == "default_photo.gif"
  end

  def modal_name
    name.downcase.tr(" ", "-") if name.present?
  end

  def send_email_to_hr
    UserMailer.profile_updated(self.changes, self.user.name).deliver!
  end

end
