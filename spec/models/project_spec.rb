require 'rails_helper'

RSpec.describe Project, type: :model do

  it 'is not valid without a name' do
    expect(build(:project, name: nil)).to_not be_valid
  end

  it 'is not valid without belonging to a Program' do
    expect(build(:project, program: nil)).to_not be_valid
  end

end
