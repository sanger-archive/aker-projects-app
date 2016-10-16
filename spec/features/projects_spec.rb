require 'rails_helper'

RSpec.feature "Projects", type: :feature do

  let (:project) { create(:project) }

  context 'when I visit a Project page' do

    before do
      visit project_path(project)
    end

    it 'will display the Project name' do
      expect(page).to have_content(project.name)
    end
  end

end
