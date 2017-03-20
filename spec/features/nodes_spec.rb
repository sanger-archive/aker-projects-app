require 'rails_helper'

RSpec.describe 'Nodes', type: :feature do

	context 'when I visit the node#show page', js: true do

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
		before do
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
			expect(page.find(:css, '#edit-panel', visible: false)).to_not be_visible
		end

		context 'when I click a node in the tree' do

			before do
				page.find('div', class: 'node', text: @root.name).click
			end

			it 'shows the edit panel' do
				expect(page.find_by_id('edit-panel').visible?).to be(true)
			end

			it 'shows selected node' do
				page.find('div', class: 'node', text: @program1.name).click
				expect(page.find_by_id('selected-node').value).to eq @program1.name
			end

		end

		describe 'adding nodes' do
			it 'can add a new child node' do
				expect do
					page.find('div', class: 'node', text: @program1.name).click
					page.fill_in 'New Node:', :with => 'child'
					click_button 'Add Child Node'
					wait_for_ajax
				end.to change{@program1.nodes.count}.by(1)
			end
		end

		describe 'deleting nodes' do
			context 'when a node has children' do
				before do
					page.find('div', class: 'node', text: @root.name).click
				end

				it 'disables the delete button' do
					expect(page.find_by_id('btn-delete-nodes').disabled?).to be true
				end

			end

			context 'when a node has no children' do
				before do
					page.find('div', class: 'node', text: @program1.name).click
				end

				it 'disables the delete button' do
					expect(page.find_by_id('btn-delete-nodes').disabled?).to be false
				end

			end

			it 'can delete a node' do
				expect do
					page.find('div', class: 'node', text: @program1.name).click
					click_button 'Delete'
					wait_for_ajax
				end.to change{@root.nodes.count}.by(-1)
			end
		end

		describe 'reset' do

		  context 'after selecting a node and filling in New Node' do

	    	before do
			    page.find('div', class: 'node', text: @root.name).click
			    page.fill_in 'New Node:', :with => 'child'
	    	end

			  it 'deselects the node' do
			    expect(page.find_by_id('selected-node').value).to eq @root.name
			    click_button 'Reset'
			    expect(page.find_by_id('selected-node').value).to eq ''
			  end

			  it 'clears the New Node input' do
			    expect(page.find_by_id('new-node').value).to eq 'child'
			    click_button 'Reset'
			    expect(page.find_by_id('new-node').value).to eq ''
			  end
		  end
		end

		describe 'editing nodes' do

			context 'Double-clicking a node' do
				before do
					page.find('div', class: 'node', text: @program1.name).double_click
					wait_for_ajax
				end

				it 'displays a modal with an edit form' do
					modal = page.find_by_id('editNodeModal')
					expect(modal.visible?).to be(true)
					expect(modal.has_css?('form')).to be(true)
				end

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