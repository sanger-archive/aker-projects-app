require 'rails_helper'
require 'ostruct'
require 'jwt'

RSpec.describe 'API::V1::Nodes', type: :request do
  include MockBilling

  let(:jwt) { JWT.encode({ data: { 'email' => 'user@here.com', 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }

  let(:user) { OpenStruct.new(email: 'user@here.com', groups: ['world']) }
  let(:different_user) { OpenStruct.new(email: 'other@here.com', groups: ['world']) }

  let(:headers) do
    {
      "Content-Type": "application/vnd.api+json",
      "Accept": "application/vnd.api+json",
      "HTTP_X_AUTHORISATION": jwt,
    }
  end

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

  before do
    allow(EventService).to receive(:publish)
  end

  describe 'GET' do

    before(:each) do
      node = create(:node, cost_code: valid_project_cost_code, description: "Here is my node", parent: program1)

      get api_v1_node_path(node), headers: headers
    end

    it 'returns a response of ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'conforms to the JSON API schema' do
      expect(response).to match_api_schema('jsonapi')
    end

    it 'conforms to the Nodes schema' do
      expect(response).to match_api_schema('node')
    end
  end

  describe 'filtering' do
    let!(:proposals) { create_list(:node, 3, cost_code: valid_project_cost_code, description: "This is a proposal", parent: program1) }
    let!(:nodes) { create_list(:node, 2, parent: program1) }
    let!(:deactivated_proposals) { create_list(:node, 2, deactivated_by: user.email, deactivated_datetime: DateTime.now, cost_code: valid_project_cost_code, parent: program1) }

    it 'will filter out deactivated nodes by default' do
      get api_v1_nodes_path, headers: headers

      json = JSON.parse(response.body, symbolize_names: true)
      response_data = json[:data]
      response_ids = response_data.map { |node| node[:id].to_i }
      expected_ids = (proposals + nodes + [root, program1]).pluck(:id)

      expect(response_data.length).to eql(7)
      expect(response_ids).to match_array(expected_ids)
    end

    it 'can find a deactivated node by id' do
      node = deactivated_proposals.first
      get api_v1_node_path(node), headers: headers

      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(response_data[:id].to_i).to eq(node.id)
    end

    describe '#filter[active]' do

      it 'can filter out active nodes' do
        get api_v1_nodes_path, params: { "filter[active]": "false" }, headers: headers

        json = JSON.parse(response.body, symbolize_names: true)
        response_data = json[:data]
        response_ids = response_data.map { |node| node[:id].to_i }
        expected_ids = deactivated_proposals.pluck(:id)

        expect(response_data.length).to eql(2)
        expect(response_ids).to match_array(expected_ids)
      end

    end

    describe '#filter[cost_code]' do

      context 'when using a value of _none for cost_code' do

        before(:each) do

          get api_v1_nodes_path, params: { "filter[cost_code]": "_none" }, headers: headers

          @json = JSON.parse(response.body, symbolize_names: true)
        end

        it 'returns only the nodes without a cost code' do
          expect(@json[:data].length).to eql(4)
        end

      end

      context 'when using a value of !_none for cost_code' do

        before(:each) do
          get api_v1_nodes_path, params: { "filter[cost_code]": "!_none" }, headers: headers

          @json = JSON.parse(response.body, symbolize_names: true)
        end

        it 'returns on the nodes with a cost code' do
          expect(@json[:data].length).to eq(3)
        end
      end
    end

    describe '#filter[node_type]' do

      it 'can filter nodes that represent projects' do
        get api_v1_nodes_path, params: { "filter[node_type]": "project" }, headers: headers

        json = JSON.parse(response.body, symbolize_names: true)
        response_data = json[:data]
        response_ids = response_data.map { |node| node[:id].to_i }
        expected_ids = proposals.pluck(:id)

        expect(response_data.length).to eql(proposals.length)
        expect(response_ids).to match_array(expected_ids)
      end

      it 'can filter nodes that represent subprojects' do
        mock_subproject_cost_code('S1234-450')
        subprojects = create_list(:node, 3,
          cost_code: "S1234-450", description: "This is a subproject", parent: proposals.first)
        get api_v1_nodes_path, params: { "filter[node_type]": "subproject" }, headers: headers

        json = JSON.parse(response.body, symbolize_names: true)
        response_data = json[:data]
        response_ids = response_data.map { |node| node[:id].to_i }
        expected_ids = subprojects.pluck(:id)

        expect(response_data.length).to eql(subprojects.length)
        expect(response_ids).to match_array(expected_ids)
      end
    end

    describe 'permissions' do

      describe '#readable_by' do

        before(:each) do
          @jason = create_list(:readable_node, 3, parent: program1, permitted: 'jason')
          @gary  = create_list(:readable_node, 3, parent: program1, permitted: 'gary')
          @ken   = create_list(:readable_node, 3, parent: program1, permitted: 'ken')
        end

        it 'can filter only nodes with a given readable permission' do
          get api_v1_nodes_path, params: { "filter[readable_by]": "jason" }, headers: headers

          expect(response).to have_http_status :ok

          json = JSON.parse(response.body, symbolize_names: true)
          response_data = json[:data]
          response_ids = response_data.map { |node| node[:id].to_i }
          expected_ids = @jason.pluck(:id)

          expect(response_data.length).to eql(3)
          expect(response_ids).to match_array(expected_ids)
        end

      end

      describe '#writable_by' do

        before(:each) do
          @jason = create_list(:writable_node, 3, parent: program1, permitted: 'jason')
          @gary  = create_list(:writable_node, 4, parent: program1, permitted: 'gary')
          @ken   = create_list(:writable_node, 5, parent: program1, permitted: 'ken')
        end

        it 'can filter only nodes with a given writable permission' do
          get api_v1_nodes_path, params: { "filter[writable_by]": "gary" }, headers: headers

          json = JSON.parse(response.body, symbolize_names: true)
          response_data = json[:data]
          response_ids = response_data.map { |node| node[:id].to_i }
          expected_ids = @gary.pluck(:id)

          expect(response_data.length).to eql(4)
          expect(response_ids).to match_array(expected_ids)
        end

      end

      describe '#spendable_by' do

        before(:each) do
          @jason = create_list(:spendable_node, 5, parent: program1, permitted: 'jason')
          @gary  = create_list(:spendable_node, 6, parent: program1, permitted: 'gary')
          @ken   = create_list(:spendable_node, 9, parent: program1, permitted: 'ken')
        end

        it 'can filter only nodes with a given spend permission' do
          get api_v1_nodes_path, params: { "filter[spendable_by]": "ken" }, headers: headers

          json = JSON.parse(response.body, symbolize_names: true)
          response_data = json[:data]
          response_ids = response_data.map { |node| node[:id].to_i }
          expected_ids = @ken.pluck(:id)

          expect(response_data.length).to eql(9)
          expect(response_ids).to match_array(expected_ids)
        end

      end

      describe '#with_parent_spendable_by' do
        before(:each) do
          @jason = create_list(:spendable_node, 5, parent: program1, permitted: 'jason')
          @gary  = create_list(:spendable_node, 6, parent: program1, permitted: 'gary')
          @ken   = create_list(:spendable_node, 9, parent: program1, permitted: 'ken')
          @ken_node = @ken.first
          @ken_node_2 = @ken.last
          @some_nodes = create_list(:node, 5, parent: @ken_node)
          @some_other_nodes = create_list(:node, 2, parent: @ken_node_2)
          @nodes_that_dont_match_condition = create_list(:node, 4, parent: @gary.last)
          @expected_result = [@some_nodes, @some_other_nodes].flatten
        end

        it 'can filter the nodes that have a parent with a given spend permission' do
          get api_v1_nodes_path, params: { "filter[with_parent_spendable_by]": "ken" }, headers: headers

          json = JSON.parse(response.body, symbolize_names: true)
          response_data = json[:data]
          response_ids = response_data.map { |node| node[:id].to_i }
          expected_ids = @expected_result.pluck(:id)

          expect(response_data.length).to eql(7)
          expect(response_ids).to match_array(expected_ids)
        end
      end

    end
  end

  describe 'CREATE #create' do
    let(:not_my_proj) { create(:node, parent_id: program1.id, name: 'Not my proj', owner_email: different_user.email) }
    let(:my_proj) { create(:node, parent_id: program1.id, name: 'My proj', owner_email: user.email) }
    let(:data) do
      {
        type: 'nodes',
        attributes: { name: 'Bananas' },
        relationships: { parent: { data: { type: 'nodes', id: parent.id } } },
      }
    end
    before { post api_v1_nodes_path, params: { data: data }.to_json, headers: headers }

    context 'when user does not have write permissions on the parent node (root)' do
      let(:parent) { root }
      it { expect(response).to have_http_status(:forbidden) }
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does not have write permissions on the parent node' do
      let(:parent) { not_my_proj }
      it { expect(response).to have_http_status(:forbidden) }
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does have write permissions on the parent node' do
      let(:parent) { my_proj }
      it { expect(response).to have_http_status(:created) }
      it 'should have published a create message' do
        expect(EventService).to have_received(:publish) do |message|
          expect(message.node).to eq(Node.find_by(name: 'Bananas'))
          expect(message.user).to eq(user.email)
          expect(message.event).to eq('created')
        end
      end
    end
  end

  describe 'UPDATE #update' do

    let(:data) do
      {
        id: node.id,
        type: 'nodes',
        attributes: { name: 'Strawberries' }
      }
    end

    before { patch api_v1_node_path(node), params: { data: data }.to_json, headers: headers }

    context 'when user does not have write permissions on the node' do
      let(:node) { create(:node, parent_id: program1.id, name: 'not my node', owner_email: different_user.email) }
      it { expect(response).to have_http_status(:forbidden) }
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does have write permissions on the node' do
      let(:node) { create(:node, parent_id: program1.id, name: 'my node', owner_email: user.email) }
      it { expect(response).to have_http_status(:ok) }
      it 'should have published an update message' do
        expect(EventService).to have_received(:publish) do |message|
          expect(message.node).to eq(node)
          expect(message.user).to eq(user.email)
          expect(message.event).to eq('updated')
        end
      end
    end
  end

  describe 'UPDATE #update_relationship' do

    let(:node) {
      create(:node, parent_id: program1.id, name: 'node1', owner_email: user.email)
    }

    let(:params) do
      {
        data: {
          type: 'nodes',
          id: destination.id,
        },
        relationship: 'parent',
        node_id: node.id,
      }
    end

    before { patch api_v1_node_relationships_parent_path(node), params: params.to_json, headers: headers }

    context 'when moving a node to under the root node' do
      let(:destination) { root }
      it { expect(response).to have_http_status(:forbidden) }
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does not have write permissions on the destination parent node' do
      let(:destination) { create(:node, parent_id: program1.id, name: 'not my program', owner_email: different_user.email) }
      it { expect(response).to have_http_status(:forbidden) }
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does have write permissions on the destination parent node' do
      let(:destination) { create(:node, parent_id: program1.id, name: 'my program', owner_email: user.email) }
      it { expect(response).to have_http_status(:no_content) }
      it 'should have published an update message' do
        expect(EventService).to have_received(:publish) do |message|
          expect(message.node).to eq(node)
          expect(message.user).to eq(user.email)
          expect(message.event).to eq('updated')
        end
      end
      it 'should have relocated the node' do
        expect(node.reload.parent).to eq(destination)
      end
    end
  end

  describe 'DELETE #remove' do

    before { delete api_v1_node_path(node), headers: headers }

    context 'when the node has children' do
      let(:node) do
        n = create(:node, parent_id: program1.id, name: 'parent node', owner_email: user.email)
        create(:node, parent_id: n.id, name: 'child node', owner_email: user.email)
        n
      end

      it { expect(response).to have_http_status(:bad_request) }
      it 'should not have deleted the node' do
        expect(node.reload).to be_active
      end
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does not have write permissions on the node' do
      let(:node) { create(:node, parent_id: program1.id, name: 'not my node', owner_email: different_user.email) }

      it { expect(response).to have_http_status(:forbidden) }
      it 'should not have deleted the node' do
        expect(node.reload).to be_active
      end
      it 'should not have published a message' do
        expect(EventService).not_to have_received(:publish)
      end
    end

    context 'when user does have write permissions on the node' do
      let(:node) { create(:node, parent_id: program1.id, name: 'my node', owner_email: user.email) }
      it { expect(response).to have_http_status(:accepted) }
      it 'should have deleted the node' do
        expect(node.reload).not_to be_active
      end
      it 'should have published an update message' do
        expect(EventService).to have_received(:publish) do |message|
          expect(message.node).to eq(node)
          expect(message.user).to eq(user.email)
          expect(message.event).to eq('updated')
        end
      end
    end

  end
end
