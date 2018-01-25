require 'rails_helper'

RSpec.describe EventMessage do
  let(:root) { build(:node, id: 1, name: 'root', node_uuid: SecureRandom.uuid) }
  let(:project) do
    build(:node, id: 2, name: 'proj', description: 'A node with a cost code', cost_code: 'S1234',
          node_uuid: SecureRandom.uuid, parent: root, data_release_strategy_id: SecureRandom.uuid)
  end
  let(:new_node) do
    build(:node, id: 3, name: 'newproj', node_uuid: SecureRandom.uuid, parent: root)
  end
  let(:deactivated_node) do
    build(:node, id: 4, name: 'deac', description: 'A deactivated node', node_uuid: SecureRandom.uuid,
      parent: root, deactivated_by: 'arnold', deactivated_datetime: DateTime.new(2017, 11, 5, 9, 30))
  end
  let(:trace_id) { 'my_trace_id' }
  let(:user) { 'someone@somewhere' }
  let(:event_uuid) { SecureRandom.uuid }

  describe '#generate_json' do
    let(:message) do
      Timecop.freeze do
        @timestamp = Time.now.utc.iso8601
        m = EventMessage.new(node: node, user: user, event: event)
        m.instance_variable_set(:@event_uuid, event_uuid)
        m.instance_variable_set(:@trace_id, trace_id)
        m
      end
    end

    let(:json) { JSON.parse(message.generate_json, symbolize_names: true) }
    let(:roles) { json[:roles] }
    let(:metadata) { json[:metadata] }
    let(:event) { 'updated' }

    shared_examples_for 'event message json' do
      it 'should include the event type' do
        expect(json[:event_type]).to eq('aker.events.project.'+event)
      end
      it 'should include the lims id' do
        expect(json[:lims_id]).to eq('aker')
      end
      it 'should include the event uuid' do
        expect(json[:uuid]).to eq(event_uuid)
      end
      it 'should include the event timestamp' do
        expect(json[:timestamp]).to eq(@timestamp)
      end
      it 'should include the user indentifier' do
        expect(json[:user_identifier]).to eq(user)
      end
      it 'should include the appropriate roles' do
        expect(roles.size).to eq(node.parent ? 2 : 1)
        proj_role = roles[0]
        expect(proj_role).to eq({
          role_type: 'project',
          subject_type: 'project',
          subject_friendly_name: node.name,
          subject_uuid: node.node_uuid,
        })
        if node.parent
          parent_role = roles[1]
          expect(parent_role).to eq({
            role_type: 'parent project',
            subject_type: 'project',
            subject_friendly_name: node.parent.name,
            subject_uuid: node.parent.node_uuid,
          })
        end
      end
      it 'should include the appropriate metadata' do
        expect(metadata).to eq({
          node_id: node.id,
          zipkin_trace_id: trace_id,
          owner_email: node.owner_email,
          description: node.description,
          cost_code: node.cost_code,
          deactivated_datetime: node.deactivated_datetime&.utc&.iso8601,
          deactivated_by: node.deactivated_by,
          data_release_uuid: node.data_release_strategy_id,
        })
      end

      it 'should generate the same json each time it is called from the same instance' do
        expect(JSON.parse(message.generate_json, symbolize_names: true)).to eq(json)
      end
    end

    context 'when the event is "created"' do
      let(:node) { new_node }
      let(:event) { 'created' }
      it_behaves_like 'event message json'
    end

    context 'when the node is the root' do
      let(:node) { root }
      it_behaves_like 'event message json'
    end

    context 'when the node has the usual fields filled in' do
      let(:node) { project }
      it_behaves_like 'event message json'
    end

    context 'when the event is deactivated' do
      let(:node) { deactivated_node }
      it_behaves_like 'event message json'
    end

  end

end
