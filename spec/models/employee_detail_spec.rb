require 'spec_helper'

describe EmployeeDetail do

  it { should belong_to(:designation) }

  context "validations" do
    it { should validate_presence_of(:location) }
  end
end
