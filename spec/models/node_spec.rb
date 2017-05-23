require 'rails_helper'

RSpec.describe Node, type: :model do

  before(:each) do
    allow(SetClient::Set).to receive(:create).and_return(double('Set', id: SecureRandom.uuid))
  end

  it "is not valid without a name" do
    expect(build(:node, name: nil)).to_not be_valid
  end

  it "is valid with a costcode in the correct format and without" do
    expect(build(:node, name: 'name', cost_code: 'xx')).to_not be_valid
    expect(build(:node, name: 'name', cost_code: 'S1234')).to be_valid
    expect(build(:node, name: 'name', cost_code: nil)).to be_valid
    expect(build(:node, name: 'name', cost_code: '')).to be_valid
  end

  it "is valid with both all possible attributes" do
    expect(build(:node, name: 'name', description: 'description', cost_code: 'S1234')).to be_valid
  end

  it "is valid when deactivated" do
    expect(build(:node, deactivated_by: create(:user), deactivated_datetime: DateTime.now)).to be_valid
  end

  it "is valid when active" do
    expect(build(:node, deactivated_by: nil, deactivated_datetime: nil)).to be_valid
  end

  it "is not valid with a deactivated_datetime but no deactivated_by" do
    expect(build(:node, deactivated_by: nil, deactivated_datetime: DateTime.now)).not_to be_valid
  end

  it "is not valid with a deactivated_by but no deactivated_datetime" do
    expect(build(:node, deactivated_by: create(:user), deactivated_datetime: nil)).not_to be_valid
  end

  it "is valid to be active and have active children" do
    children = create_list(:node, 3)
    parent = create(:node, nodes: children)
    expect(parent).to be_valid
  end

  it "is valid to be active and have inactive children" do
    user = create(:user)
    create_list(:node, 3, deactivated_by: user, deactivated_datetime: DateTime.now)
    parent = create(:node)
    expect(parent).to be_valid
  end

  it "is valid to be active and have partially inactive children" do
    user = create(:user)
    children = create_list(:node, 2,  deactivated_by: nil, deactivated_datetime: nil)
    children += create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now)
    parent = create(:node, nodes: children)
    expect(parent).to be_valid
  end

  it "is valid to be active and have no children" do
    expect(create(:node)).to be_valid
  end

  it "is valid to be inactive and have no children" do
    expect(create(:node, deactivated_by: create(:user), deactivated_datetime: DateTime.now)).to be_valid
  end

  it "is valid to be inactive and have inactive children" do
    user = create(:user)
    children = create_list(:node, 3, deactivated_by: user, deactivated_datetime: DateTime.now)
    parent = create(:node, nodes: children)
    parent.deactivated_by = user
    parent.deactivated_datetime = DateTime.now
    expect(parent).to be_valid
  end

  it "is invalid to be inactive and have active children" do
    user = create(:user)
    children = create_list(:node, 3)
    parent = create(:node, nodes: children)
    parent.deactivated_by = user
    parent.deactivated_datetime = DateTime.now
    expect(parent).not_to be_valid
  end

  it "is invalid to be inactive and have partially inactive children" do
    user = create(:user)
    children = create_list(:node, 2, deactivated_by: nil, deactivated_datetime: nil)
    children += create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now)
    parent = create(:node, nodes: children)
    parent.deactivated_by = user
    parent.deactivated_datetime = DateTime.now
    expect(parent).not_to be_valid
  end

  context "when creating a node with the same name as another active node" do
	  it "is invalid" do
	  	active_node = create(:node)
	  	expect(build(:node, name: active_node.name)).not_to be_valid
	  end

  end

  it "is valid to create a node with the same name as a deactivated node" do
  	user = create(:user)
  	deactivated_node = create(:node, deactivated_by: user, deactivated_datetime: DateTime.now)
  	expect(build(:node, name: deactivated_node.name)).to be_valid
  end

  describe '#level' do

    before do
      @root = create(:node, name: 'root', parent_id: nil)
      @node = create(:node, name: 'SOME NAME', collection: @collection, parent: @root)
    end

    it 'returns the level of the node in the tree' do
      expect(@root.level).to eq(1)
      expect(@node.level).to eq(2)
    end

  end

  describe '#destroy' do
    context 'when it is a level 2 node (program)' do
      before do
        @collection = create(:collection, set_id: SecureRandom.uuid)
        @root = create(:node, name: 'root', parent_id: nil)
        @node = create(:node, name: 'SOME NAME', collection: @collection, parent: @root)
      end

      it 'nullifies the set of the collection' do
        expect(@node.collection).to receive(:nullify).and_return(true).at_least(:once)
        @node.destroy
      end
    end
  end

  context 'when other nodes exist' do

    before do
      @root = create(:node, name: "root", parent_id: nil)
      @program = create(:node, name: "program", parent: @root)
    end

    it "must have unique name" do
      expect(build(:node, name: "program", parent: @root)).to_not be_valid
    end
    it "is not valid with invalid parent_id" do
      expect(build(:node, name: "thing", parent_id: 0)).to_not be_valid
    end

    it "knows if it is the root node" do
      expect(@root.root?).to be_truthy
      expect(@program.root?).to be_falsey
    end

    context 'when successfully created a child node' do

      before do
        @node = create(:node, name: 'jeff', parent: @program)
      end
      it "must be valid" do
        expect(@node).to be_valid
      end
      it "must have the given name" do
        expect(@node.name).to eq('jeff')
      end
      it "must have the given parent_id" do
        expect(@node.parent_id).to eq(@program.id)
      end
      it "must have the given parent" do
        expect(@node.parent).to eq(@program)
      end
      it "must be a child of the parent" do
        expect(@program.nodes).to include(@node)
      end
      it "must know its parents" do |variable|
        @child = create(:node, name: 'bill', parent: @node)
        expect(@child.parents).to include(@node, @program)
      end
    end

  end

  describe '#active?' do
    context 'when deactivated_by is null' do
      before do
        @node = build(:node)
      end

      it 'is active' do
        expect(@node.active?).to eq(true)
      end
    end

    context 'description' do
      before do
        @node = build(:node, deactivated_by: create(:user))
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
        @active_nodes = create_list(:node, 3)
        @inactive_nodes = create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now)
      end

      it 'should return only the active nodes' do
        expect(Node.active).to match_array(@active_nodes)
      end

      it 'should be possible to get the inactive nodes' do
        expect(Node.all).to match_array(@active_nodes+@inactive_nodes)
      end
    end
  end

  describe "#deactivate" do
    context 'when node is active' do
      before do
        @node = create(:node)
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
        @node = create(:node, deactivated_by: @user1, deactivated_datetime: @deactivation_time)
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
    		@node = create(:node)
    	end
    	it 'raises an ArgumentError' do
    		expect { @node.deactivate(@user) }.to raise_error(ArgumentError)
    	end
    end
  end

  describe '#active_children' do

  	before do
  		user = create(:user)
  		@active_children = create_list(:node, 2,  deactivated_by: nil, deactivated_datetime: nil)
  		@deactivated_children = create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now)
  		@parent = create(:node, nodes: @active_children + @deactivated_children)
  	end


    it 'returns all active children' do
    	expect(@parent.active_children).to match_array(@active_children)
    end
  end
end
