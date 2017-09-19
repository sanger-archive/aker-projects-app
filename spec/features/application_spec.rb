require 'rails_helper'

RSpec.describe 'Application', type: :feature do

  #TODO these tests rely on redirect to login page, which is
  #  not yet ready
  describe "title tests" do
    xit "displays correct title" do
      visit root_path
      expect(page).to have_title("Aker - WTSI Research Activity Model")
    end
  end

  describe "class selector tests" do
    xit "displays login in standard container" do
      visit root_path
      expect(page).not_to have_css('div', :class => "container-fluid")
      expect(page).to have_css('div', :class => "container")
    end
  end
end
