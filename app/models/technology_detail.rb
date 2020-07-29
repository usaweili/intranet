class TechnologyDetail
  include Mongoid::Document

  field :name
  field :version
  belongs_to :project
  belongs_to :open_source_project
  validates_presence_of :name, message: "Technology Name can't be blank", if: 'version.present?'
  validates_presence_of :version, message: "Version can't be blank", if: 'name.present?'
end
