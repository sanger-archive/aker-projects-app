require 'rails_helper'

RSpec.describe Proposal, type: :model do

  it 'is not valid without a name' do
    expect(build(:proposal, name: nil)).to_not be_valid
  end

  it 'is not valid without belonging to an Aim' do
    expect(build(:proposal, aim: nil)).to_not be_valid
  end
end
