class CodeClimateStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
  field :timestamp
  field :gpa # Grade Point Average
  field :test_coverage
  field :loc, default: {} # Language-wise LOC
  field :maintainability
  field :remediation_minutes
  field :technical_debt_ratio
  field :diff_coverage
  field :ratings, default: {} # File types from A to F 
  belongs_to :repository
  validates_presence_of :timestamp
end
