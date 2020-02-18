class ClippContact
  include Mongoid::Document

  field :name,       :type => String
  field :email,      :type => String
  field :website,   :type => String
  field :phone,      :type => String
  field :comment,    :type => String

  validates_presence_of :name, :email, :website, :phone, :comment
end
