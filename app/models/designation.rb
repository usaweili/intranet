class Designation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  belongs_to :parent_designation, class_name: 'Designation'

  validates :name, presence: true, uniqueness: true
end
