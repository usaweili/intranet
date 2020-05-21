class EntryPass
  include Mongoid::Document
  field :date, type: Date
  belongs_to :user
end
