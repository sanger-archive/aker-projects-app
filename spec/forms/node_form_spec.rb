require 'rails_helper'

RSpec.describe NodeForm do
  let(:user) { create(:user) }
  describe '#new' do
    let(:form) { NodeForm.new(name: 'dirk', description: 'foo', cake: 'banana', owner: user, group_writers: 'zombies,pirates') }

    it 'has the attributes specified that are in the ATTRIBUTES list' do
      expect(form.name).to eq 'dirk'
      expect(form.description).to eq('foo')
      expect(form.group_writers).to eq('zombies,pirates')
    end
    it 'has nil for attributes that were not specified' do
      expect(form.id).to be_nil
      expect(form.parent_id).to be_nil
      expect(form.user_writers).to be_nil
      expect(form.user_spenders).to be_nil
      expect(form.group_spenders).to be_nil
    end
    it 'has the owner specified' do
      expect(form.instance_variable_get('@owner')).to eq(user)
    end
  end

  describe '#from_node' do
    let(:node) do 
      permissions = [
        build(:permission, permitted: 'world', permission_type: :read),
        build(:permission, permitted: user.email, permission_type: :write),
        build(:permission, permitted: 'dirk@sanger.ac.uk', permission_type: :write),
        build(:permission, permitted: 'pirates', permission_type: :write),
        build(:permission, permitted: 'ninjas', permission_type: :write),
        build(:permission, permitted: 'dirk@sanger.ac.uk', permission_type: :spend),
        build(:permission, permitted: 'jeff@sanger.ac.uk', permission_type: :spend),
      ]
      build(:node, id: 17, parent_id: 16, name: 'mynode', description: 'desc',
          cost_code: 'S1234', permissions: permissions, owner: user)
    end
    let(:form) { NodeForm.from_node(node) }

    it 'has fields matching the node' do
      expect(form.id).to eq(17)
      expect(form.parent_id).to eq(16)
      expect(form.name).to eq('mynode')
      expect(form.description).to eq('desc')
      expect(form.cost_code).to eq('S1234')
    end
    it 'has the owner specified' do
      expect(form.instance_variable_get('@owner')).to eq(user)
    end
    it 'has the correct permissions' do
      expect(form.user_writers).to eq('dirk@sanger.ac.uk')
      expect(form.group_writers).to eq('pirates,ninjas')
      expect(form.user_spenders).to eq('dirk@sanger.ac.uk,jeff@sanger.ac.uk')
      expect(form.group_spenders).to eq('')
    end
  end

  describe '#save' do
    let(:root) do
      r = build(:node, name: 'root', parent_id: nil)
      r.save!(validate: false)
      r
    end
    let(:program) do
      pr = build(:node, name: 'program', parent: root)
      pr.save!(validate: false)
      pr.permissions.create!([{permitted: user.email, permission_type: :write}])
      pr
    end
    let(:project) do
      pr = create(:node, name: 'project', description: 'desc', cost_code: 'S1234', parent: program, owner: user)
    end

    context 'when the form represents a new node' do
      let(:form) { NodeForm.new(name: 'jelly', description: 'foo', parent_id: program.id, owner: user, cost_code: 'S1234', user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas') }

      before { @result = form.save }

      it { expect(@result).to be_truthy }

      it 'creates a node as described' do
        node = Node.find_by(name: 'jelly')
        expect(node).not_to be_nil
        expect(node.name).to eq('jelly')
        expect(node.cost_code).to eq('S1234')
        expect(node.description).to eq('foo')
        expect(node.parent).to eq(program)
        expect(node.id).not_to be_nil
        expect(node.owner).to eq(user)
      end

      it 'sets up the correct permissions' do
        node = Node.find_by(name: 'jelly')
        permissions = node.permissions.map { |perm| [perm.permitted, perm.permission_type.to_sym] }
        expected = [
          [user.email, :read],
          [user.email, :write],
          ['world', :read],
          ['dirk@sanger.ac.uk', :write],
          ['jeff@sanger.ac.uk', :write],
          ['zombies', :write],
          ['pirates', :write],
          ['dirk@sanger.ac.uk', :spend],
          ['ninjas', :spend],
        ]
        expect(permissions).to match_array(expected)
      end
    end

    context 'when the form represents an existing node' do
      let(:form) { NodeForm.new(id: project.id, name: 'jelly', description: 'foo', parent_id: project.parent_id, cost_code: 'S0000', user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas') }

      before { @result = form.save }

      it { expect(@result).to be_truthy }

      it 'updates the node' do
        node = Node.find(project.id)
        expect(node.name).to eq('jelly')
        expect(node.description).to eq('foo')
        expect(node.cost_code).to eq('S0000')
        expect(node.parent).to eq(program)
        expect(node.owner).to eq(user) # no change
      end

      it 'sets up the correct permissions' do
        node = Node.find(project.id)
        permissions = node.permissions.map { |perm| [perm.permitted, perm.permission_type.to_sym] }
        expected = [
          [user.email, :read],
          [user.email, :write],
          ['world', :read],
          ['dirk@sanger.ac.uk', :write],
          ['jeff@sanger.ac.uk', :write],
          ['zombies', :write],
          ['pirates', :write],
          ['dirk@sanger.ac.uk', :spend],
          ['ninjas', :spend],
        ]
        expect(permissions).to match_array(expected)
      end
    end

    context 'when the node cannot be created' do
      let(:form) { NodeForm.new(name: 'jelly', description: 'foo', parent_id: program.id, owner: user, cost_code: 'S1234', user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas') }
      it "returns false and doesn't create the node" do
        allow(form).to receive(:convert_permissions).and_raise('Kaboom')
        expect(form.save).to be_falsey
        expect(Node.find_by(name: 'jelly')).to be_nil
      end
    end

    context 'when the node cannot be updated' do
      let(:form) { NodeForm.new(id: project.id, name: 'jelly', description: 'foo', parent_id: project.parent_id, cost_code: 'S0000', user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas') }
      it "returns false and doesn't update the node" do
        allow(form).to receive(:convert_permissions).and_raise('Kaboom')
        expect(form.save).to be_falsey
        node = Node.find(project.id)
        expect(node.name).to eq('project') # change has been rolled back
      end
    end
  end
end