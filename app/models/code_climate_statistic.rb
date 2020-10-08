class CodeClimateStatistic
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lines_of_code,        type: Integer, default: 0
  field :total_issues,         type: Integer, default: 0
  field :complexity_issues,    type: Integer, default: 0
  field :duplication_issues,   type: Integer, default: 0
  field :maintainability,      type: Float,   default: 0.0
  field :quality_gpa,          type: Float,   default: 0.0
  field :remediation_time,     type: Float,   default: 0.0
  field :implementation_time,  type: Float,   default: 0.0
  field :test_coverage,        type: Float,   default: 0.0
  field :technical_debt_ratio, type: Float,   default: 0.0

  belongs_to :repository
end
