require 'rails_helper'

RSpec.describe Aim, type: :model do

  it 'is not valid without a name' do
    expect(build(:aim, name: nil)).to_not be_valid
  end

  it 'is not valid without belonging to a Project' do
    expect(build(:aim, project: nil)).to_not be_valid
  end

end
