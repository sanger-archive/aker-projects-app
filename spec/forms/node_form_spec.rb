require 'rails_helper'
require 'ostruct'
require 'support/mock_billing'

RSpec.describe NodeForm do

  include MockBilling

  let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }

  let(:some_email) { 'some@email' }

  let(:root) {
    root = build(:node, name: 'root', owner_email: user.email)
    root.save(validate: false)
    root
  }

  let(:data_release_strategy) { build(:data_release_strategy) }

  describe '#new' do
    let(:form) {
      NodeForm.new(name: 'dirk', description: 'foo', cake: 'banana', user_email: user.email,
        owner_email: user.email, group_writers: 'zombies,pirates')
    }

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
      expect(form.instance_variable_get('@owner_email')).to eq(user.email)
    end
    it 'has the user email specified' do
      expect(form.instance_variable_get('@user_email')).to eq(user.email)
    end
    it 'has nil for the data release strategy' do
      expect(form.data_release_strategy_id).to be_nil
    end

    context 'when defining the data release strategy' do
      let(:node) {NodeForm.new(name: 'dirk', data_release_strategy_id: strategy_id, description: 'foo', cake: 'banana',
        owner_email: user.email, user_email: user.email, group_writers: 'zombies,pirates') }
      context 'when the data release is an empty string' do
        let(:strategy_id) {''}
        it 'has nil ' do
          expect(node.data_release_strategy_id).to eq(nil)
        end
      end
      context 'when the data release is nil' do
        let(:strategy_id) {nil}
        it 'has nil ' do
          expect(node.data_release_strategy_id).to eq(nil)
        end
      end
      context 'when the data release is defined' do
        let(:strategy) { create :data_release_strategy }
        let(:strategy_id) {strategy.id}
        it 'has the id for the strategy ' do
          expect(node.data_release_strategy_id).to eq(strategy_id)
        end
      end
    end
  end

  describe '#from_node' do
    let(:node) {
      node = build(:node, name: 'node', owner_email: user.email, parent: root)
      node.save(validate: false)
      node
    }
    let(:project) do
      project = create(:node, parent_id: node.id, name: 'project', description: 'desc',
        data_release_strategy_id: data_release_strategy.id,
          cost_code: valid_project_cost_code, owner_email: user.email)

      permissions = [
        build(:permission, permitted: 'dirk@sanger.ac.uk', permission_type: :write),
        build(:permission, permitted: 'pirates', permission_type: :write),
        build(:permission, permitted: 'ninjas', permission_type: :write),
        build(:permission, permitted: 'dirk@sanger.ac.uk', permission_type: :spend),
        build(:permission, permitted: 'jeff@sanger.ac.uk', permission_type: :spend),
      ]
      project.permissions << permissions
      project
    end
    let(:form) { NodeForm.from_node(project, some_email) }

    it 'has fields matching the node' do
      expect(form.id).to eq(project.id)
      expect(form.parent_id).to eq(node.id)
      expect(form.name).to eq('project')
      expect(form.description).to eq('desc')
      expect(form.cost_code).to eq(valid_project_cost_code)
    end
    it 'has the owner specified' do
      expect(form.instance_variable_get('@owner_email')).to eq(user.email)
    end
    it 'has the data release strategy uuid specified' do
      expect(form.instance_variable_get('@data_release_strategy_id')).to eq(data_release_strategy.id)
    end
    it 'has the user specified' do
      expect(form.instance_variable_get('@user_email')).to eq(some_email)
    end
    it 'has the correct permissions' do
      expect(form.user_writers).to eq('dirk@sanger.ac.uk')
      expect(form.group_writers.split(',').sort).to eq(['pirates','ninjas'].sort)
      expect(form.user_spenders.split(',').sort).to eq(['jeff@sanger.ac.uk','dirk@sanger.ac.uk'].sort)
      expect(form.group_spenders).to eq('')
    end

    context 'if node is a subproject' do
      let(:subproject) { create(:node, name: 'subproject', cost_code: valid_subproject_cost_code, parent: project, owner_email: user.email)}
      let(:form) { NodeForm.from_node(subproject, some_email) }

      it 'should have the permissions of its parent' do
        expect(subproject.permissions).to eq(project.permissions)
      end

      it 'should not have permissions individually stored' do
        expect(AkerPermissionGem::Permission.where(accessible_id: subproject.id)).to be_empty
      end

      it 'has fields matching the node' do
        expect(form.id).to eq(subproject.id)
        expect(form.parent_id).to eq(project.id)
        expect(form.name).to eq('subproject')
        expect(form.description).to eq(nil)
        expect(form.cost_code).to eq(valid_subproject_cost_code)
      end
      it 'has the owner specified' do
        expect(form.instance_variable_get('@owner_email')).to eq(user.email)
      end
      it 'has the user specified' do
        expect(form.instance_variable_get('@user_email')).to eq(some_email)
      end
      it 'has the correct permissions matching the parent node' do
        #expect(form.group_readers).to eq('world')
        expect(form.user_writers).to eq('dirk@sanger.ac.uk')
        expect(form.group_writers.split(',').sort).to eq(['pirates','ninjas'].sort)
        expect(form.user_spenders.split(',').sort).to eq(['jeff@sanger.ac.uk','dirk@sanger.ac.uk'].sort)
        expect(form.group_spenders).to eq('')
      end

    end
  end

  describe '#valid?' do
    context 'when using different values for data release strategy id' do
      before do
        allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user)
      end
      let(:form) { NodeForm.new(name: 'jelly', description: 'foo',
        data_release_strategy_id: strategy_id,
        user_email: user.email,
        parent_id: root.id, owner_email: user.email, cost_code: valid_project_cost_code,
        user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK',
        group_spenders: 'ninjas') }

      context 'when it is nil' do
        let(:strategy_id) { nil }
        it 'is valid' do
          expect(form.valid?).to eq(true)
        end
        it 'does not check the external service' do
          form.valid?
          expect(DataReleaseStrategyClient).not_to have_received(:find_strategies_by_user)
        end
      end
      context 'when is empty string' do
        let(:strategy_id) { '' }
        it 'is valid' do
          expect(form.valid?).to eq(true)
        end
        it 'does not check the external service' do
          form.valid?
          expect(DataReleaseStrategyClient).not_to have_received(:find_strategies_by_user)
        end
      end
      context 'when is a uuid' do
        let(:strategy) { create :data_release_strategy }
        let(:strategy_id) { strategy.id }
        before do
          allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).with(user.email).and_return([strategy])
        end

        it 'checks the external service' do
          form.valid?
          expect(DataReleaseStrategyClient).to have_received(:find_strategies_by_user)
        end
        context 'when the strategy is in the list returned by the service' do
          before do
            allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).with(user.email).and_return([strategy])
          end
          it 'is valid' do
            expect(form.valid?).to eq(true)
          end
        end
        context 'when the strategy selected is not in the list' do
          before do
            allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).with(user.email).and_return([])
          end

          it 'is not valid' do
            expect(form.valid?).to eq(false)
          end
        end
      end
      context 'when is some random hacky text' do
        before do
          allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).with(user.email).and_return([])
        end

        let(:strategy_id) { '; DELETE * FROM users;' }
        it 'is not valid' do
          expect(form.valid?).to eq(false)
        end
        it 'generates an error because it is not a uuid' do
          form.valid?
          expect(form.errors.messages[:data_release_strategy_id].first).to include('UUID')
        end
      end
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
      pr = create(:node, name: 'project', description: 'desc', cost_code: valid_project_cost_code,
        parent: program, owner_email: user.email)
    end

    context 'when the form represents a new node' do
      let(:form) do
        NodeForm.new(name: 'jelly', description: 'foo', parent_id: program.id, owner_email: user.email,
          data_release_strategy_id: data_release_strategy.id,
          cost_code: valid_project_cost_code, user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES',
          user_spenders: 'DIRK', group_spenders: 'ninjas', user_email: some_email)
      end

      before {
        @result = form.save
      }

      it { expect(@result).to be_truthy }

      it 'creates a node as described' do
        node = Node.find_by(name: 'jelly')
        expect(node).not_to be_nil
        expect(node.name).to eq('jelly')
        expect(node.cost_code).to eq(valid_project_cost_code)
        expect(node.description).to eq('foo')
        expect(node.parent).to eq(program)
        expect(node.id).not_to be_nil
        expect(node.owner_email).to eq(user.email)
      end

      it 'sets up the correct permissions' do
        node = Node.find_by(name: 'jelly')
        permissions = node.permissions.map { |perm| [perm.permitted, perm.permission_type.to_sym] }
        expected = [
          [user.email, :read],
          [user.email, :write],
          [user.email, :spend],
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

      it 'sets up the correct data release policy' do
        node = Node.find_by(name: 'jelly')
        expect(node.data_release_strategy_id).to eq(data_release_strategy.id)
      end
    end

    context 'when the form represents an existing node' do
      let(:form) do
        NodeForm.new(id: project.id, name: 'jelly', description: 'foo', parent_id: project.parent_id,
          data_release_strategy_id: data_release_strategy.id,
          cost_code: another_valid_project_cost_code,
                     user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas', user_email: some_email)
      end

      before { @result = form.save }

      it { expect(@result).to be_truthy }

      it 'updates the node' do
        node = Node.find(project.id)
        expect(node.name).to eq('jelly')
        expect(node.description).to eq('foo')
        expect(node.cost_code).to eq(another_valid_project_cost_code)
        expect(node.parent).to eq(program)
        expect(node.owner_email).to eq(user.email) # no change
      end

      it 'sets up the correct permissions' do
        node = Node.find(project.id)
        permissions = node.permissions.map { |perm| [perm.permitted, perm.permission_type.to_sym] }
        expected = [
          [user.email, :read],
          [user.email, :write],
          [user.email, :spend],
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
      it 'sets up the correct data release policy' do
        node = Node.find(project.id)
        expect(node.data_release_strategy_id).to eq(data_release_strategy.id)
      end

    end

    context 'when the node cannot be created' do
      let(:form) do
        NodeForm.new(name: 'jelly', description: 'foo', parent_id: program.id, owner_email: user.email, cost_code: valid_project_cost_code,
                     user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas', user_email: some_email)
      end

      before do
        allow(form).to receive(:convert_permissions).and_raise('Kaboom')
        @result = form.save
      end

      it { expect(@result).to be_falsey }

      it "should not create the node" do
        expect(Node.find_by(name: 'jelly')).to be_nil
      end

    end

    context 'when the node cannot be updated' do
      let(:form) do
        NodeForm.new(id: project.id, name: 'jelly', description: 'foo', parent_id: project.parent_id, cost_code: another_valid_project_cost_code,
                     user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas', user_email: some_email)
      end

      before do
        allow(form).to receive(:convert_permissions).and_raise('Kaboom')
        @result = form.save
      end

      it { expect(@result).to be_falsey }

      it "should not update the node" do
        node = Node.find(project.id)
        expect(node.name).to eq('project') # change has been rolled back
      end
    end

    context 'when selecting a data release strategy' do
      let(:current_strategy) { create(:data_release_strategy) }
      let(:strategy) { create(:data_release_strategy)}
      let(:form) { NodeForm.new(id: project.id, data_release_strategy_id: strategy.id, user_email: user.email, name: 'jelly', description: 'foo', parent_id: project.parent_id, cost_code: another_valid_project_cost_code, user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas') }

      context 'when the strategy selected is not valid for the current user' do
        before do
          allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).and_return([current_strategy])
          project.update_attributes!(data_release_strategy_id: current_strategy.id)
        end

        it 'does not update the node' do
          expect(form.save).to be_falsey
          project.reload
          expect(project.data_release_strategy_id).to eq(current_strategy.id)
        end

        context 'but if the node already has the data release strategy the user is trying to set' do
          before do
            project.update_attributes!(data_release_strategy_id: strategy.id)
          end
          it 'updates the node' do
            expect(form.save).to be_truthy
            project.reload
            expect(project.data_release_strategy_id).to eq(strategy.id)
          end
        end
      end
      context 'when the strategy selected is valid for the current user' do
        before do
          allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).and_return([strategy])
        end

        it 'does update the node' do
          expect(form.save).to be_truthy
          project.reload
          expect(project.data_release_strategy_id).to eq(strategy.id)
        end
      end
      context 'when no strategy has been selected' do
        let(:form) { NodeForm.new(id: project.id, data_release_strategy_id: nil, user_email: user.email, name: 'jelly', description: 'foo', parent_id: project.parent_id, cost_code: another_valid_project_cost_code, user_writers: 'dirk,jeff', group_writers: 'zombies,   PIRATES', user_spenders: 'DIRK', group_spenders: 'ninjas') }

        before do
          allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).and_return([strategy])
        end

        it 'does update the node' do
          project.reload
          project.update_attributes!(data_release_strategy_id: current_strategy.id)
          expect(project.data_release_strategy_id).to eq(current_strategy.id)
          expect(form.save).to be_truthy
          project.reload
          expect(project.data_release_strategy_id).to eq(nil)
        end
      end

    end

  end
end