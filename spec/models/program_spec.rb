require 'rails_helper'
require_relative 'concerns/collector_shared_example'

RSpec.describe Program, type: :model do

  it_behaves_like "collector"

  it "is not valid without a name" do
    expect(build(:program, name: nil)).to_not be_valid
  end

end
