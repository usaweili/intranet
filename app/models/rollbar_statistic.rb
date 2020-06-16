class RollbarStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :repository
  field :date
  field :total_issues
  field :active_issue_count
  field :resolved_issue_count
  field :new_issue_count # Occured for the first time in the given week.
  validates_presence_of :date, :repository
end
