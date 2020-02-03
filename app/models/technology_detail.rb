class TechnologyDetail
  include Mongoid::Document

  field :name
  field :version
  belongs_to :project
  validates_presence_of :version, message: "Version #{'name'}can't be blank", if: 'name.present?'
end