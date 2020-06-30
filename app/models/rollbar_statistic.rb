class RollbarStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :repository
  field :date
  field :total_issues, type: Integer, default: 0
  field :active_issue_count, type: Integer, default: 0
  field :resolved_issue_count, type: Integer, default: 0
  field :new_issue_count, type: Integer, default: 0 # Occured for the first time in the given week.
  validates_presence_of :date, :repository
end
