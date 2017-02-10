require 'rails_helper'

RSpec.describe 'Nodes', type: :feature do

	context 'when I visit the node#show page' do

	  	before do
			@root = create(:node, name: "root", parent_id: nil)
			@program1 = create(:node, name: "program1", parent: @root)
			@program2 = create(:node, name: "program2", parent: @root)

			visit root_path
		end

	    it 'displays a list of Sanger programs' do
	      expect(page).to have_content('Sanger Programs')
	      expect(page).to have_link('program1', href: node_path(@program1.id))
	      expect(page).to have_link('program2', href: node_path(@program2.id))
	    end

		it "you cannot edit or delete program level nodes" do
		  expect(page).not_to have_content('Edit')
		  expect(page).not_to have_content('Delete')
		end
	end


	context 'when i visit node#id#show page' do |variable|
		before do
			@root = create(:node, name: "root", parent_id: nil)
			@program1 = create(:node, name: "program1", parent: @root)
			@program11 = create(:node, name: "program11", parent: @program1)
			visit node_path(@program1.id)
		end

		it "page displays children to node" do
		    expect(page).to have_content('program11')
		    expect(page).to have_content('Edit')
	  		expect(page).to have_content('Delete')
		end

	end
	
end