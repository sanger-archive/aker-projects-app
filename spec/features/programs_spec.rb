require 'rails_helper'

RSpec.describe 'Programs', type: :feature do

  let(:program) { create(:program) }

  context 'when I a Program page' do

    before do
      visit program_path(program)
    end

    it 'displays the name of the Program' do
      expect(page).to have_content(program.name)
    end

  end

end