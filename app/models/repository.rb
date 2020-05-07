class Repository
  include Mongoid::Document
  HOSTS = ['GitHub', 'BitBucket', 'GitLab', 'SourceForge', 'Launchpad', 'Google Cloud', 'AWS CodeCommit'].freeze
  belongs_to :project
  field :name
  field :host
  field :url
  field :code_climate_id
  field :maintainability_badge
  field :test_coverage_badge
  # validates_presence_of :name, :url, :host
  # validates :host, inclusion: { in: HOSTS, allow_nil: false }
  has_many :code_climate_statistics
end
