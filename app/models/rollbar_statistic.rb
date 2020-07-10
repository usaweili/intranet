class RollbarStatistic
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :repository
  field :date
  field :total_issues, type: Integer
  field :active_issue_count, type: Integer
  field :resolved_issue_count, type: Integer
  field :new_issue_count, type: Integer # Occured for the first time in the given week.
  validates_presence_of :date, :repository
end
