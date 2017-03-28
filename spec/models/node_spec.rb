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
end
