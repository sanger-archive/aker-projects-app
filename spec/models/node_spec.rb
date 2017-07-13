require 'rails_helper'

RSpec.describe Node, type: :model do

  let(:root) {
    n = build(:node, name: 'root', parent_id: nil)
    n.save(validate: false)
    n
  }

  let(:program1) {
    n = build(:node, name: 'program1', parent: root, owner: create(:user))
    n.save(validate: false)
    n
  }

  before(:each) do
    allow(SetClient::Set).to receive(:create).and_return(double('Set', id: SecureRandom.uuid))
  end

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

  it "is not valid without a name" do
    expect(build(:node, name: nil, parent: program1)).to_not be_valid
  end

  it "is not valid without a parent" do
    root.reload
    expect(build(:node, name: 'name')).to_not be_valid
  end

  it "is valid with a costcode in the correct format and without" do
    expect(build(:node, name: 'name', cost_code: 'xx', parent: program1)).to_not be_valid
    expect(build(:node, name: 'name', cost_code: 'S1234', parent: program1)).to be_valid
    expect(build(:node, name: 'name', cost_code: nil, parent: program1)).to be_valid
    expect(build(:node, name: 'name', cost_code: '', parent: program1)).to be_valid
  end

  it "is valid with all possible attributes" do
    expect(build(:node, name: 'name', description: 'description', cost_code: 'S1234', parent: program1)).to be_valid
  end

  it "is valid when deactivated" do
    expect(build(:node, deactivated_by: create(:user), deactivated_datetime: DateTime.now, parent: program1)).to be_valid
  end

  it "is valid when active" do
    expect(build(:node, deactivated_by: nil, deactivated_datetime: nil, parent: program1)).to be_valid
  end

  it "is not valid with a deactivated_datetime but no deactivated_by" do
    expect(build(:node, deactivated_by: nil, deactivated_datetime: DateTime.now, parent: program1)).not_to be_valid
  end

  it "is not valid with a deactivated_by but no deactivated_datetime" do
    expect(build(:node, deactivated_by: create(:user), deactivated_datetime: nil, parent: program1)).not_to be_valid
  end

  it "is valid to be active and have active children" do
    children = create_list(:node, 3, parent: program1)
    expect(program1.nodes).to eq children
  end

  it "is valid to be active and have inactive children" do
    user = create(:user)
    children = create_list(:node, 3, deactivated_by: user, deactivated_datetime: DateTime.now, parent: program1)
    expect(program1.nodes).to eq children
  end

  it "is valid to be active and have partially inactive children" do
    user = create(:user)
    children = create_list(:node, 2,  deactivated_by: nil, deactivated_datetime: nil, parent: program1)
    children += create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now, parent: program1)
    expect(program1.nodes).to eq children
  end

  it "is valid to be active and have no children" do
    expect(create(:node, parent: program1)).to be_valid
  end

  it "is valid to be inactive and have no children" do
    expect(create(:node, deactivated_by: create(:user), deactivated_datetime: DateTime.now, parent: program1)).to be_valid
  end

  it "is valid to be inactive and have inactive children" do
    user = create(:user)
    prog1 = create(:node, parent: program1)
    children = create_list(:node, 3, deactivated_by: user, deactivated_datetime: DateTime.now, parent: prog1)
    expect(prog1.nodes).to eq children
    prog1.deactivated_by = user
    prog1.deactivated_datetime = DateTime.now
    expect(prog1).to be_valid
  end

  it "is invalid to be inactive and have active children" do
    user = create(:user)
    prog1 = create(:node, parent: program1)
    children = create_list(:node, 3, parent: prog1)
    expect(prog1.nodes).to eq children
    prog1.deactivated_by = user
    prog1.deactivated_datetime = DateTime.now
    expect(prog1).not_to be_valid
  end

  it "is invalid to be inactive and have partially inactive children" do
    user = create(:user)
    prog1 = create(:node, parent: program1)
    children = create_list(:node, 2, deactivated_by: nil, deactivated_datetime: nil, parent: prog1)
    children += create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now, parent: prog1)
    prog1.deactivated_by = user
    prog1.deactivated_datetime = DateTime.now
    expect(prog1).not_to be_valid
  end

  it "is invalid to creat a node with the same name as another active node" do
  	active_node = create(:node, parent: program1)
  	expect(build(:node, name: active_node.name, parent: program1)).not_to be_valid
	 end

  it "is valid to create a node with the same name as a deactivated node" do
  	user = create(:user)
  	deactivated_node = create(:node, deactivated_by: user, deactivated_datetime: DateTime.now, parent: program1)
  	expect(build(:node, name: deactivated_node.name, parent: program1)).to be_valid
  end

  it "is invalid to create a root node" do
    user = create(:user)
    root.reload
    expect(build(:node, name: 'root', parent: nil)).not_to be_valid
  end

  it "is invalid to create a node under root" do
    user = create(:user)
    expect(build(:node, name: 'prog1', parent: root)).not_to be_valid
  end

  it "is invalid to move a node to under root" do
    user = create(:user)
    node =  build(:node, name: 'prog1', parent: program1)
    node.update_attributes(parent_id: root.id)
    expect(node).not_to be_valid
  end

  it "is invalid to move a node from under root" do
    user = create(:user)
    program3 = create(:node, name: 'program3', parent: program1, owner: user)
    program4 = build(:node, name: 'program4', parent: root, owner: user)
    program4.save(validate: false)
    expect(program4.update_attributes(parent_id: program3.id)).to eq false
  end

  it "is invalid to destroy the root node" do
    root.destroy
    expect(root.errors[:base]).to eq ["The root node can not be deleted"]
  end

  it "is invalid to destroy a node under the root node" do
    program1.destroy
    expect(program1.errors[:base]).to eq ["A node under the root node can not be deleted"]
  end

  context '#create' do
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
      expect(root.errors[:base]).to eq ["The root node cannot be created/updated."]
    end
  end

  describe '#destroy' do
    it 'the root node can not be destroyed' do
      root.destroy
      expect(root.errors[:base]).to eq ["The root node can not be deleted"]
    end

    it 'a node under the root node can not be destroyed' do
      program1.destroy
      expect(program1.errors[:base]).to eq ["A node under the root node can not be deleted"]
    end

    it 'a node with children can not be destroyed' do
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
        @node = build(:node, deactivated_by: create(:user), parent: program1)
      end

      it 'is not active' do
        expect(@node.active?).to eq(false)
      end
    end
  end

  describe "#active" do
    context 'when some things are active' do
      before do
        user = create(:user)
        @active_nodes = create_list(:node, 3, parent: program1)
        @inactive_nodes = create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now, parent: program1)
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
        @user = create(:user)
        @node.deactivate(@user)
      end
      it 'should not be active' do
        expect(@node).not_to be_active
      end
      it 'should be deactivated_by the given user' do
        expect(@node.deactivated_by).to eq(@user)
      end
      it 'should have a deactivated datetime' do
        expect(@node.deactivated_datetime).not_to be_nil
      end
    end
    context 'when node is already deactivated' do
      before do
        @deactivation_time = 3.days.ago
        @user1 = create(:user)
        @user2 = create(:user)
        @node = create(:node, deactivated_by: @user1, deactivated_datetime: @deactivation_time, parent: program1)
        @node.deactivate(@user2)
      end
      it 'should still not be active' do
        expect(@node).not_to be_active
      end
      it 'should still be deactivated_by the original deactivating user' do
        expect(@node.deactivated_by).to eq(@user1)
      end
      it 'should still have the original deactivated_datetime' do
        expect(@node.deactivated_datetime).to eq(@deactivation_time)
      end
    end
    context 'when user does not have an id' do
    	before do
    		@user = build(:user)
    	end
    	it 'raises an ArgumentError' do
    		expect { program1.deactivate(@user) }.to raise_error(ArgumentError)
    	end
    end
  end

  describe '#active_children' do

  	before do
  		user = create(:user)
  		@active_children = create_list(:node, 2,  deactivated_by: nil, deactivated_datetime: nil, parent: program1)
  		@deactivated_children = create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now, parent: program1)
  	end

    it 'returns all active children' do
    	expect(program1.active_children).to match_array(@active_children)
    end
  end
end
