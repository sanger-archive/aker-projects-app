# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgChart::Tree do

  let(:root) {
    n = build(:node, name: 'root')
    n.save(validate: false)
    n
  }

  let(:program1) {
    n = build(:node, name: 'program1', parent: root, owner_email: user.email)
    n.save(validate: false)
    n
  }

  let(:project) { build(:project, parent: program1) }
  let(:sub_project) { build(:sub_project, parent: project) }
  let(:writable_node) { create(:writable_node, permitted: 'cs24@sanger.ac.uk', owner_email: user.email, parent: program1) }
  let(:spendable_node) { create(:spendable_node, permitted: 'cs24@sanger.ac.uk', owner_email: user.email, parent: program1) }
  let(:org_chart_tree) { OrgChart::Tree.new(node: root, user: user) }
  let(:user) { build(:user) }

  it 'sets the id' do
    expect(org_chart_tree.id).to eq(root.id.to_s)
  end

  it 'sets the node name' do
    expect(org_chart_tree.name).to eq(root.name)
  end

  it 'sets the cost code' do
    expect(org_chart_tree.cost_code).to eq(root.cost_code)
  end

  it 'sets the href' do
    expect(org_chart_tree.href).to eq(root.id.to_s)
  end

  it 'sets the owner' do
    expect(org_chart_tree.owner).to eq(root.owner_email)
  end

  describe 'node_type' do

    context 'when node is a project' do
      it 'sets node_type to project' do
        org_chart_tree = OrgChart::Tree.new(node: project, user: user)
        expect(org_chart_tree.node_type).to eq('project')
      end
    end

    context 'when node is a sub_project' do
      it 'sets node_type to sub-project' do
        org_chart_tree = OrgChart::Tree.new(node: sub_project, user: user)
        expect(org_chart_tree.node_type).to eq('sub-project')
      end
    end

    context 'when node is neither a project nor sub-project' do
      it 'sets node_type to organisational' do
        expect(org_chart_tree.node_type).to eq('organisational')
      end
    end

  end

  describe 'writers' do

    it 'lists the users and groups with edit permission' do
      org_chart_tree = OrgChart::Tree.new(node: writable_node, user: user)

      writers = writable_node.permissions.lazy
        .select { |perm| perm.permission_type == 'write' }
        .map { |perm| perm.permitted }
        .force

      expect(org_chart_tree.writers).to eq(writers)
    end

  end

  describe 'spenders' do

    it 'lists the users and groups with spend permission' do
      org_chart_tree = OrgChart::Tree.new(node: spendable_node, user: user)

      spenders = spendable_node.permissions.lazy
        .select { |perm| perm.permission_type == 'spend' }
        .map { |perm| perm.permitted }
        .force

      expect(org_chart_tree.spenders).to eq(spenders)
    end
  end

  describe 'parentId' do

    it 'sets the parentId' do
      org_chart_tree = OrgChart::Tree.new(node: project, user: user)
      expect(org_chart_tree.parentId).to eq(project.parent_id.to_s)
    end

  end

  describe 'relationship' do

    context 'when node has a parent' do
      it 'sets the first character to 1' do
        node = create(:node, owner_email: user.email, parent: program1)
        org_chart_tree = OrgChart::Tree.new(node: node, user: user)
        expect(org_chart_tree.relationship.length).to eq(3)
        expect(org_chart_tree.relationship[0]).to eq("1")
      end
    end

    context 'when node has no parent' do
      it 'sets the first character to 0' do
        expect(org_chart_tree.relationship.length).to eq(3)
        expect(org_chart_tree.relationship[0]).to eq("0")
      end
    end

    context 'when node has siblings' do
      it 'sets the second character to 1' do
        node = create(:node, owner_email: user.email, parent: program1)
        sibling = create(:node, owner_email: user.email, parent: program1)
        org_chart_tree = OrgChart::Tree.new(node: node, user: user)
        expect(org_chart_tree.relationship.length).to eq(3)
        expect(org_chart_tree.relationship[1]).to eq("1")
      end
    end

    context 'when node has no siblings' do
      it 'sets the second character to 0' do
        expect(org_chart_tree.relationship.length).to eq(3)
        expect(org_chart_tree.relationship[1]).to eq("0")
      end
    end

    context 'when node has children' do
      it 'sets the third character to 1' do
        root.nodes << program1
        org_chart_tree = OrgChart::Tree.new(node: root, user: user)
        expect(org_chart_tree.relationship.length).to eq(3)
        expect(org_chart_tree.relationship[2]).to eq("1")
      end
    end

    context 'when node has no children' do
      it 'sets the third character to 0' do
        expect(org_chart_tree.relationship.length).to eq(3)
        expect(org_chart_tree.relationship[2]).to eq("0")
      end
    end

  end

  describe 'to_h' do

    it 'returns a hash with the correct keys and values' do
      project.save(validate: false)
      children = create_list(:node, 3, parent_id: project.id)
      org_chart_tree = OrgChart::Tree.new(node: project, user: user)
      result = org_chart_tree.to_h
      expect(result).to be_kind_of(Hash)
      expect(result[:cost_code]).to eq(org_chart_tree.cost_code)
      expect(result[:id]).to eq(org_chart_tree.id)
      expect(result[:node_type]).to eq(org_chart_tree.node_type)
      expect(result[:name]).to eq(org_chart_tree.name)
      expect(result[:href]).to eq(org_chart_tree.href)
      expect(result[:relationship]).to eq(org_chart_tree.relationship)
      expect(result[:parentId]).to eq(org_chart_tree.parentId)
      expect(result[:writers]).to eq(org_chart_tree.writers)
      expect(result[:spenders]).to eq(org_chart_tree.spenders)
      expect(result[:children]).to be_kind_of(Array)
      expect(result[:children].length).to eq(children.length)
    end

  end

end