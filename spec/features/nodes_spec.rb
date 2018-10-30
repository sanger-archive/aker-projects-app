require 'rails_helper'
require 'ostruct'

RSpec.describe 'Nodes', type: :feature do

  let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }

  let(:user2) { OpenStruct.new(email: 'user2@sanger.ac.uk', groups: ['world']) }

  let!(:root) do
    n = build(:node, name: 'root')
    n.save!(validate: false)
    n
  end

  let!(:program1) do
    n = build(:node, name: 'program1', parent: root, owner_email: user.email)
    n.save!(validate: false)
    n
  end

  let!(:program2) do
    n = build(:node, name: 'program2', parent: root)
    n.save!(validate: false)
    n.permissions.create!(permitted: user.email, permission_type: :write)
    n
  end

  let!(:program3) do
    n = build(:node, name: 'program3', parent: root)
    n.save!(validate: false)
    n
  end

  let!(:proj) do
    create(:node, name: 'proj1', parent: program3, owner_email: user.email)
  end

  let!(:proj2) do
    create(:node, name: 'proj2', parent: program3, owner_email: user2.email)
  end

  let!(:proj_with_costcode) do
    create(:project, name: 'Proj with costcode', parent: proj2, owner_email: user.email)
  end

  let!(:subproj) do
    create(:node, name: 'subproj', parent: proj_with_costcode, owner_email: user.email)
  end

  before do
    allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
    allow_any_instance_of(JWTCredentials).to receive(:current_user)
      .and_return(user)
  end

  context 'when I visit the Tree Hierarchy', js: true do
    before do
      visit tree_nodes_path
    end

    it 'shows the tree hierarchy' do
      expect(page.find_by_id('tree-hierarchy').visible?).to be(true)
    end

    it 'shows the edit panel' do
      expect(page.find(:css, '#edit-panel', visible: true)).to be_visible
    end

    describe 'clicking nodes' do
      context 'when I click a node' do

        before do
          page.find('div', class: 'node', text: root.name).click
        end

        it 'shows the edit panel' do
          expect(page.find_by_id('edit-panel').visible?).to be(true)
        end

        it 'shows selected node' do
          page.find('div', class: 'node', text: program1.name).click
          expect(page.find_by_id('selected-node').value).to eq program1.name
        end

      end

      context 'when I click a subproject' do

        it 'disables the "Add Node" button' do
          page.find('div', class: 'node', text: subproj.name).click
          expect(page.find_by_id('btn-add-nodes').disabled?).to be true
        end

      end

    end

    describe 'adding nodes' do
      it 'can add a new child node' do
        expect do
          page.find('div', class: 'node', text: program1.name).click
          page.fill_in 'New Node:', with: 'child'
          click_button 'Add Node'
          wait_for_ajax
        end.to change { program1.nodes.count }.by(1)
      end

      context 'when a node with the same name already exists' do
        it 'notifies the user the node can not be created' do
          page.find('div', class: 'node', text: program1.name).click
          page.fill_in 'New Node:', with: program1.name
          click_button 'Add Node'
          wait_for_ajax
          expect(page).to have_content("name - must be unique")
        end
      end

    end

    describe 'deleting nodes' do
      context 'when a node has children' do
        before do
          page.find('div', class: 'node', text: root.name).click
        end

        it 'disables the delete button' do
          expect(page.find_by_id('btn-delete-nodes').disabled?).to be true
        end
      end

      context 'when a node has no children' do
        before do
          page.find('div', class: 'node', text: program1.name).click
        end

        it 'enables the delete button' do
          expect(page.find_by_id('btn-delete-nodes').disabled?).to be false
        end
      end

      it 'can delete a node lower down owned by the user' do
        page.find('div', class: 'node', text: proj.name).click
        click_button 'Delete'
        wait_for_ajax
        expect(proj.reload).not_to be_active
      end

      it 'cannot delete a node lower down owned by another user' do
        page.find('div', class: 'node', text: proj2.name).click
        expect(page).not_to have_button('Delete')
      end

      context 'when a node is the only one visible' do
        before do
          page.find('div', class: 'node', text: program2.name)
              .find('i', class: 'verticalEdge').trigger('click')
        end

        it 'reloads the whole tree' do
          expect(page.find('div', class: 'orgchart'))
            .to_not have_content(root.name)
          page.find('div', class: 'node', text: program2.name).click
          click_button 'Delete'
          wait_for_ajax
          expect(page.find('div', class: 'orgchart')).to have_content(root.name)
        end
      end
    end

    describe 'selecting a node' do
      context 'after selecting a node and filling in New Node' do
        before do
          page.find('div', class: 'node', text: program2.name).click
          page.fill_in 'New Node:', with: 'child'
        end

        it 'deselects the node' do
          expect(page.find_by_id('selected-node').value).to eq program2.name
          page.find('div', class: 'node', text: root.name).click
          expect(page.find_by_id('selected-node').value).to eq root.name
        end

      end
    end

    describe 'expanding tree' do
      context 'when some nodes are hidden and EXPAND TREE is clicked' do
        before do
          page.find('div', class: 'node', text: program2.name)
              .find('i', class: 'verticalEdge').trigger('click')
        end

        it 'reloads the whole tree' do
          expect(page.find('div', class: 'orgchart')).to_not have_content(root.name)
          click_button 'Expand Tree'
          expect(page.find('div', class: 'orgchart')).to have_content(root.name)
        end
      end
    end

    describe 'editing nodes' do
      context 'Double-clicking a node' do
        let(:modal) { page.find_by_id('editNodeModal') }

        let(:double_clicking_subproj) {
          page.find('div', class: 'node', text: subproj.name).double_click
          wait_for_ajax
        }
        it 'displays a modal with an edit form' do
          double_clicking_subproj

          expect(modal.visible?).to be(true)
          expect(modal.has_css?('form')).to be(true)
        end
      end
    end
  end

  describe '/nodes/tree' do
    before do
      visit tree_nodes_path
    end

    it 'shows me the tree view' do
      expect(page).to have_css('#tree')
    end
  end
end
