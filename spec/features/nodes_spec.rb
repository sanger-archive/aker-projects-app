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

	context 'when I visit the Tree Hierarchy', js: true do
		before 'allows you visit the Tree Hierarchy' do
			@root = create(:node, name: "root", parent_id: nil)
			@program1 = create(:node, name: "program1", parent: @root)
			@program2 = create(:node, name: "program2", parent: @root)

			visit root_path
			click_link "Tree Hierarchy"
		end

		it 'shows the tree hierarchy' do
			expect(page.find_by_id('tree-hierarchy').visible?).to be(true)
		end

		it 'does not show the edit panel' do
			expect(page.find(:css, '#edit-panel')).to_not be_visible
		end

		context 'when I click a node in the tree' do

			before do
				page.find('div', class: 'node', text: @root.name).click
			end

			it 'shows the edit panel' do
				expect(page.find_by_id('edit-panel').visible?).to be(true)
			end
		end

	end


	context 'when i visit node#id#show page' do |variable|
		before do
			@root = create(:node, name: "root", parent_id: nil)
			@program1 = create(:node, name: "program1", parent: @root)
			@program11 = create(:node, name: "program11", parent: @program1)
			visit node_path(@program1.id)
		end

		it "displays children to node" do
		    expect(page).to have_content('program11')
		    expect(page).to have_content('Edit')
	  		expect(page).to have_content('Delete')
		end

		context 'when node is a proposal' do
			before do
				@proposal = create(:node, cost_code: "S1234", description: "My super proposal")
				visit node_path(@proposal)
			end

			it "displays the cost code" do
				expect(page).to have_content(@proposal.cost_code)
			end

			it "displays the description" do
				expect(page).to have_content(@proposal.description)
			end
		end

	end

end