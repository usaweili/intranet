class Training
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps

  TYPES = ['Hackathon', 'Community']

  field :subject,             type: String
  field :objectives,           type: String
  field :date,                type: Date
  field :venue,               type: String
  field :showcase_on_website, type: Boolean, default: false
  field :duration
  field :video
  field :blog_link
  field :ppt

  slug :subject

  has_many :file_attachments, dependent: :destroy
  accepts_nested_attributes_for :file_attachments

  has_many :chapters, class_name: 'Training', dependent: :destroy
  belongs_to :training
  accepts_nested_attributes_for :chapters, reject_if: :chapter_record_is_blank?

  belongs_to :trainer, class_name: 'User'
  belongs_to :training

  has_many :technology_details
  accepts_nested_attributes_for :technology_details, allow_destroy: true

  validates_presence_of :subject, :objectives, :duration
  scope :showcase_on_website, -> {training_only.where(showcase_on_website: true)}
  # training_only is for those records who are not chapters as the training has a self association
  scope :training_only, -> {where(training_id: nil)}

  def chapter_record_is_blank?(attributes)
    attributes[:subject].blank?  and attributes[:objective].blank? and attributes[:duration].blank?
  end

  def photos
    file_attachments.where(type: 'photo').collect(&:doc)
  end

  def ppts
    file_attachments.where(type: 'ppt').collect(&:doc)
  end
end
