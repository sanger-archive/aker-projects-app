require 'rails_helper'

RSpec.describe 'Application', type: :feature do
  describe "title tests" do
    it "displays correct title" do
      visit root_path
      expect(page).to have_title("Aker - WTSI Research Activity Model")
    end
  end

  describe "class selector tests" do
    it "displays login in standard container" do
      visit root_path
      expect(page).not_to have_css('div', :class => "container-fluid")
      expect(page).to have_css('div', :class => "container")
    end
  end
end
