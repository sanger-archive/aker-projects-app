require 'rails_helper'

RSpec.describe Collection, type: :model do

  context 'when given a set_id that does not look like a uuid' do
    it 'is not valid' do
      expect(build(:collection, set_id: 'not a uuid')).to_not be_valid
    end
  end

  it 'has a set_id after creation' do
    expect(create(:collection).set_id).to_not be_nil
  end

end
