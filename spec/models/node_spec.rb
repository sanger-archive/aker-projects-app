require 'rails_helper'
require 'cancan/matchers'
require 'ostruct'

RSpec.describe Node, type: :model do

  include MockBilling

  let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }

  let(:root) {
    n = build(:node, name: 'root', parent_id: nil)
    n.save(validate: false)
    n
  }

  let(:program1) {
    n = build(:node, name: 'program1', parent: root, owner_email: user.email)
    n.save(validate: false)
    n
  }

  it "has a uuid" do
    expect(root).to have_attribute('node_uuid')
  end

  it "has the same uuid after reloading again" do
    nodes = create_list(:node, 3, parent: program1)
    node = nodes.first
    reloaded_node = nodes.find(node.id).first
    expect(reloaded_node.node_uuid).to eq nodes.first.node_uuid
  end

  it "a node under root does not have an owner" do
    expect(program1).not_to have_attribute('owner')
  end

  it "the root node does not have an owner" do
    expect(root).not_to have_attribute('owner')
  end

  describe '#validation' do
    context 'depending on the cost code' do
      it 'is not valid if the cost code does not have the right format' do
        expect(build(:node, name: 'parent', cost_code: 'xx', parent: program1)).to_not be_valid
      end
      context 'when my node is a project' do
        it 'is valid if it has a project cost code' do
          expect(build(:node, name: 'name', cost_code: valid_project_cost_code, parent: program1)).to be_valid
        end
        it 'is not valid if it has a subproject cost code' do
          expect(build(:node, name: 'name', cost_code: valid_subproject_cost_code, parent: program1)).to be_invalid
        end
        it 'is not valid if it has an invalid cost code' do
          expect(build(:node, name: 'name', cost_code: 'xxx', parent: program1)).to be_invalid
        end
        it 'is valid if it has no cost code' do
          expect(build(:node, name: 'name', parent: program1)).to be_valid
        end
      end
      context 'when my node is a subproject' do
        let(:parent_node) { create(:node, name: 'parent', cost_code: valid_project_cost_code, parent: program1) }
        it 'is valid if it has a subproject cost code' do
          expect(build(:node, name: 'name', cost_code: valid_subproject_cost_code, parent: parent_node)).to be_valid
        end
        it 'is not valid if it has a project cost code' do
          expect(build(:node, name: 'name', cost_code: valid_project_cost_code, parent: parent_node)).to be_invalid
        end
        it 'is not valid if it has an invalid cost code' do
          expect(build(:node, name: 'name', cost_code: 'xxx', parent: parent_node)).to be_invalid
        end
        it 'is valid if it has no cost code' do
          expect(build(:node, name: 'name', parent: parent_node)).to be_valid
        end
      end
      context 'when the node is neither a project or a subproject' do
        it 'is invalid if it has a subproject cost code' do
          expect(build(:node, name: 'name', cost_code: valid_subproject_cost_code, parent: program1)).to be_invalid
        end
        it 'is invalid if it has an invalid cost code' do
          expect(build(:node, name: 'name', cost_code: 'xxx', parent: program1)).to be_invalid
        end
        it 'is valid if it has no cost code' do
          expect(build(:node, name: 'name', parent: program1)).to be_valid
        end
      end
    end

    it "is not valid without a name" do
      expect(build(:node, name: nil, parent: program1)).to_not be_valid
    end

    it "is not valid without a parent" do
      root.reload
      expect(build(:node, name: 'name')).to_not be_valid
    end

    it "is valid with a costcode in the correct format and without" do
      expect(build(:node, name: 'name', cost_code: 'xx', parent: program1)).to_not be_valid
      expect(build(:node, name: 'name', cost_code: valid_project_cost_code, parent: program1)).to be_valid
      expect(build(:node, name: 'name', cost_code: nil, parent: program1)).to be_valid
      expect(build(:node, name: 'name', cost_code: '', parent: program1)).to be_valid
    end

    it "is valid with all possible attributes" do
      expect(build(:node, name: 'name', description: 'description', cost_code: valid_project_cost_code, parent: program1)).to be_valid
    end

    it "is valid when deactivated" do
      expect(build(:node, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)).to be_valid
    end

    it "is valid when active" do
      expect(build(:node, deactivated_by: nil, deactivated_datetime: nil, parent: program1)).to be_valid
    end

    it "is not valid with a deactivated_datetime but no deactivated_by" do
      expect(build(:node, deactivated_by: nil, deactivated_datetime: DateTime.now, parent: program1)).not_to be_valid
    end

    it "is not valid with a deactivated_by but no deactivated_datetime" do
      expect(build(:node, deactivated_by: user.email, deactivated_datetime: nil, parent: program1)).not_to be_valid
    end

    it "is valid to be active and have active children" do
      children = create_list(:node, 3, parent: program1)
      expect(program1.nodes).to match_array children
    end

    it "is valid to be active and have inactive children" do
      children = create_list(:node, 3, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)
      expect(program1.nodes).to match_array children
    end

    it "is valid to be active and have partially inactive children" do
      children = create_list(:node, 2,  deactivated_by: nil, deactivated_datetime: nil, parent: program1)
      children += create_list(:node, 2, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)
      expect(program1.nodes).to match_array children
    end

    it "is valid to be active and have no children" do
      expect(create(:node, parent: program1)).to be_valid
    end

    it "is valid to be inactive and have no children" do
      expect(create(:node, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)).to be_valid
    end

    it "is valid to be inactive and have inactive children" do
      prog1 = create(:node, parent: program1)
      children = create_list(:node, 3, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: prog1)
      expect(prog1.nodes).to match_array children
      prog1.deactivated_by = user
      prog1.deactivated_datetime = DateTime.now
      expect(prog1).to be_valid
    end

    it "is invalid to be inactive and have active children" do
      prog1 = create(:node, parent: program1)
      children = create_list(:node, 3, parent: prog1)
      expect(prog1.nodes).to match_array children
      prog1.deactivated_by = user.email
      prog1.deactivated_datetime = DateTime.now
      expect(prog1).not_to be_valid
    end

    it "is invalid to be inactive and have partially inactive children" do
      prog1 = create(:node, parent: program1)
      children = create_list(:node, 2, deactivated_by: nil, deactivated_datetime: nil, parent: prog1)
      children += create_list(:node, 2, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: prog1)
      prog1.deactivated_by = user.email
      prog1.deactivated_datetime = DateTime.now
      expect(prog1).not_to be_valid
    end

    it "is invalid to create a node with the same name as another active node" do
    	active_node = create(:node, parent: program1)
    	expect(build(:node, name: active_node.name, parent: program1)).not_to be_valid
  	 end

    it "is valid to create a node with the same name as a deactivated node" do
    	deactivated_node = create(:node, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)
    	expect(build(:node, name: deactivated_node.name, parent: program1)).to be_valid
    end

    it "is invalid to create a root node" do
      root.reload
      expect(build(:node, name: 'root', parent: nil)).not_to be_valid
    end

    it "is invalid to create a node under root" do
      expect(build(:node, name: 'prog1', parent: root)).not_to be_valid
    end

    it "is invalid to move a node to under root" do
      node =  build(:node, name: 'prog1', parent: program1)
      node.update_attributes(parent_id: root.id)
      expect(node).not_to be_valid
    end

    it "is invalid to move a node from under root" do
      program3 = create(:node, name: 'program3', parent: program1, owner_email: user.email)
      program4 = build(:node, name: 'program4', parent: root, owner_email: user.email)
      program4.save(validate: false)
      expect(program4.update_attributes(parent_id: program3.id)).to eq false
    end

    it "is invalid to destroy the root node" do
      root.destroy
      expect(root.errors[:base]).to eq ["The root node cannot be deleted"]
    end

    it 'should not be valid without a sanitised name' do
      expect(build(:node, parent: program1, name: "   \t  \n   ")).not_to be_valid
    end
    it 'should not be valid without a sanitised owner' do
      expect(build(:node, parent: program1, owner_email: "   \t  \n   ")).not_to be_valid
    end
    it 'should be valid after sanitisation if fields are not empty' do
      expect(build(:node, parent: program1, name: "   \tALPHA\n   ", owner_email: "   \tALPHA\n   ")).to be_valid
    end

  end

  describe '#create' do
    before do
      @node = create(:node, name: 'jeff', parent: program1)
    end

    it "must be valid" do
      expect(@node).to be_valid
    end
    it "must have the given name" do
      expect(@node.name).to eq('jeff')
    end
    it "must have the given parent_id" do
      expect(@node.parent_id).to eq(program1.id)
    end
    it "must have the given parent" do
      expect(@node.parent).to eq(program1)
    end
    it "must be a child of the parent" do
      expect(program1.nodes).to include(@node)
    end
    it "must know its parents" do |variable|
      @child = create(:node, name: 'bill', parent: @node)
      expect(@child.parents).to include(@node, program1)
    end
  end

  describe '#update' do
    it "the root node cannot be updated" do
      root.update_attributes(name: 'Still root')
      expect(root.errors[:base]).to eq ["The root node cannot be created/updated"]
    end

    context 'when a project has subprojects' do
      before do
        @project = create(:node, name: 'project', cost_code: valid_project_cost_code, parent: program1)
        @subproject = create(:node, name: 'subproject', cost_code: valid_subproject_cost_code, parent: @project)
      end

      it 'should be invalid when trying to update the cost code' do
        @project.update_attributes(cost_code: another_valid_project_cost_code)
        expect(@project).not_to be_valid
      end
      it 'should be valid when trying to update, not changing the cost code' do
        @project.update_attributes(cost_code: valid_project_cost_code)
        expect(@project).to be_valid
      end
    end

  end

  describe '#destroy' do
    it 'the root node cannot be destroyed' do
      root.destroy
      expect(root.errors[:base]).to eq ["The root node cannot be deleted"]
    end

    it 'a node with children cannot be destroyed' do
      node1 = create(:node, name: 'node1', parent: program1)
      node2 = create(:node, name: 'node2', parent: node1)
      node1.destroy
      expect(node1.errors[:base]).to eq ["Cannot delete record because dependent nodes exist"]
    end
  end

  describe '#root?' do
    it "knows if it is the root node" do
      expect(root.root?).to be_truthy
      expect(program1.root?).to be_falsey
    end
  end

  describe '#level' do
    it 'returns the level of the node in the tree' do
      node = create(:node, name: 'node', parent: program1)
      expect(root.level).to eq(1)
      expect(program1.level).to eq(2)
      expect(node.level).to eq(3)
    end
  end

  describe '#active?' do
    context 'when deactivated_by is null' do
      before do
        @node = build(:node, parent: program1)
      end

      it 'is active' do
        expect(@node.active?).to eq(true)
      end
    end

    context 'when deactivated_by is a user' do
      before do
        @node = build(:node, deactivated_by: user.email, parent: program1)
      end

      it 'is not active' do
        expect(@node.active?).to eq(false)
      end
    end
  end

  describe "#active" do
    context 'when some things are active' do
      before do
        @active_nodes = create_list(:node, 3, parent: program1)
        @inactive_nodes = create_list(:node, 2, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)
        @all_active_nodes = @active_nodes+[program1, root]
      end

      it 'should return only the active nodes' do
        expect(Node.active).to match_array(@all_active_nodes)
      end

      it 'should be possible to get the inactive nodes' do
        expect(Node.all).to match_array(@all_active_nodes+@inactive_nodes)
      end
    end
  end

  describe "#deactivate" do
    context 'when node is active' do
      before do
        @node = create(:node, parent: program1)
        @node.deactivate(user.email)
      end
      it 'should not be active' do
        expect(@node).not_to be_active
      end
      it 'should be deactivated_by the given user' do
        expect(@node.deactivated_by).to eq(user.email)
      end
      it 'should have a deactivated datetime' do
        expect(@node.deactivated_datetime).not_to be_nil
      end
    end
    context 'when node is already deactivated' do
      before do
        @deactivation_time = 3.days.ago
        @user1 = OpenStruct.new(email: 'user1@sanger.ac.uk', groups: ['world'])
        @user2 = OpenStruct.new(email: 'user2@sanger.ac.uk', groups: ['world'])
        @node = create(:node, deactivated_by: @user1.email, deactivated_datetime: @deactivation_time, parent: program1)
        @node.deactivate(@user2.email)
      end
      it 'should still not be active' do
        expect(@node).not_to be_active
      end
      it 'should still be deactivated_by the original deactivating user' do
        expect(@node.deactivated_by).to eq(@user1.email)
      end
      it 'should still have the original deactivated_datetime' do
        expect(@node.deactivated_datetime).to eq(@deactivation_time)
      end
    end
  end

  describe '#active_children' do

  	before do
  		@active_children = create_list(:node, 2,  deactivated_by: nil, deactivated_datetime: nil, parent: program1)
  		@deactivated_children = create_list(:node, 2, deactivated_by: user.email, deactivated_datetime: DateTime.now, parent: program1)
  	end

    it 'returns all active children' do
    	expect(program1.active_children).to match_array(@active_children)
    end
  end

  describe '#accessible' do
    let(:owner) { OpenStruct.new(email: 'jeff@email', groups: ['world']) }
    subject(:ability) { Ability.new(user) }
    let(:node) do
      n = create(:node, parent: program1, owner_email: owner.email)
      n.permissions.create([{ permitted: 'dirk@email', permission_type: :write }, { permitted: 'mygroup', permission_type: :write }])
      n
    end

    context 'when the user has permission' do
      let(:user) { OpenStruct.new(email: 'dirk@email', groups: ['world']) }
      it { should be_able_to(:read, node) }
      it { should be_able_to(:write, node) }
      it { should_not be_able_to(:spend, node) }
    end

    context 'when the user has no permission' do
      let(:user) { OpenStruct.new(email: 'fred@email', groups: ['world']) }
      it { should be_able_to(:read, node) }
      it { should_not be_able_to(:write, node) }
      it { should_not be_able_to(:spend, node) }
    end

    context 'when the user owns the node' do
      let(:user) { owner }
      it { should be_able_to(:read, node) }
      it { should be_able_to(:write, node) }
      it { should be_able_to(:spend, node) }
    end

    context 'when the user has group permission' do
      let(:user) { OpenStruct.new(email: 'zog@email', groups: ['world', 'mygroup']) }
      it { should be_able_to(:read, node) }
      it { should be_able_to(:write, node) }
      it { should_not be_able_to(:spend, node) }
    end
  end

  describe '#name' do
    it 'should be sanitised' do
      expect(create(:node, name: '   ALPHA   BETA  ', parent: program1).name).to eq('ALPHA BETA')
    end
  end

  describe '#owner_email' do
    it 'should be sanitised' do
      expect(create(:node, owner_email: '   ALPHA@BETA  ', parent: program1).owner_email).to eq('alpha@beta')
    end
  end

  describe '#deactivated_by' do
    it 'should be sanitised' do
      expect(create(:node, parent: program1, deactivated_datetime: DateTime.now, deactivated_by: '  ALPHA@BETA  ').deactivated_by).to eq('alpha@beta')
    end
  end

  describe '#is_project?' do
    context 'when node is the root node' do
      it 'is returns false' do
        expect(root.is_project?).to eq false
      end
    end
    context 'when node is a subproject node' do
      let(:project) { create(:node, name: 'project', cost_code: valid_project_cost_code, parent: program1) }
      it 'is returns false' do
        subproject = create(:node, name: 'subproject', parent: project)
        expect(subproject.is_project?).to eq false
      end
    end
    context 'when node has a cost code and parent has a cost code' do
      let(:project) { create(:node, name: 'project', cost_code: valid_project_cost_code, parent: program1) }
      it 'is returns false' do
        subproject = build(:node, name: 'subproject', cost_code: 'xxx', parent: project)
        expect(subproject.is_project?).to eq false
      end
    end
    context 'when node doesnt have a cost code and parent has a cost code' do
      let(:project) { create(:node, name: 'project', cost_code: valid_project_cost_code, parent: program1) }
      let(:program2) { create(:node, name: 'program2', parent: project) }
      it 'is returns false' do
        expect(program2.is_project?).to eq false
      end
    end
    context 'when node doesnt have a cost code and no parent cost code' do
      let(:program2) { create(:node, name: 'program2', parent: program1) }
      it 'is returns false' do
        expect(program2.is_project?).to eq false
      end
    end
    context 'when node has a cost code but no parent cost code' do
      let(:project) { create(:node, name: 'project', cost_code: valid_project_cost_code, parent: program1) }
      it 'is returns true' do
        expect(project.is_project?).to eq true
      end
    end
  end
end