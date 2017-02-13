	require 'rails_helper'
require_relative 'concerns/collector_shared_example'

RSpec.describe Node, type: :model do

	it "is not valid without a name" do
		expect(build(:node, name: nil)).to_not be_valid
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
