require 'rails_helper'

RSpec.describe TreeLayout, type: :model do
  describe '#user_id' do
    it 'should be sanitised' do
      expect(create(:tree_layout, user_id: '    ALPHA@BETA   ').user_id).to eq('alpha@beta')
    end
  end

  describe 'validation' do
    it 'should not be valid without a user id' do
      expect(build(:tree_layout, user_id: "   \n  \t   ")).not_to be_valid
    end
    it 'should not be valid without a unique sanitised user id' do
      create(:tree_layout, user_id: 'alpha@beta')
      expect(build(:tree_layout, user_id: '    ALPHA@BETA  ')).not_to be_valid
    end
    it 'should be valid with a unique user id' do
      create(:tree_layout, user_id: 'alpha@beta')
      expect(build(:tree_layout, user_id: '    GAMMA@DELTA  ')).to be_valid
    end
  end

end
