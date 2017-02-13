require 'rails_helper'

RSpec.describe Program, type: :model do

  it "is not valid without a name" do
    expect(build(:program, name: nil)).to_not be_valid
  end

end
