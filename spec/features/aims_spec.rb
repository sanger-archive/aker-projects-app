require 'rails_helper'

RSpec.feature "Aims", type: :feature do

  let(:aim) { create(:aim) }

  context 'when I visit an Aim page' do

    before do
      visit aim_path(aim)
    end

    it 'will display the Aim name' do
      expect(page).to have_content(aim.name)
    end

  end
end
