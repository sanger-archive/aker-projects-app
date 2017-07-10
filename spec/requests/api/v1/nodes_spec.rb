require 'rails_helper'

RSpec.describe 'API::V1::Nodes', type: :request do

  let(:headers) do
    {
      "Content-Type": "application/vnd.api+json",
      "Accept": "application/vnd.api+json"
    }
  end

  describe 'GET' do
    before(:each) do
      user = create(:user)
      sign_in user

      node = create(:node, cost_code: "S1234", description: "Here is my node")

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
    before(:each) do
      sign_in user
    end

    let!(:proposals) { create_list(:node, 3, cost_code: "S1234", description: "This is a proposal") }
    let!(:nodes) { create_list(:node, 2) }
    let!(:user) { create(:user) }
    let!(:deactivated_proposals) { create_list(:node, 2, deactivated_by: user, deactivated_datetime: DateTime.now, cost_code: "S1234") }

    context 'when using a value of _none for cost_code' do

      before(:each) do

        get api_v1_nodes_path, params: { "filter[cost_code]": "_none" }, headers: headers

        @json = JSON.parse(response.body, symbolize_names: true)
      end

      it 'returns only the nodes without a cost code' do
        expect(@json[:data].length).to eql(2)
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

    it 'will filter out deactivated nodes by default' do
      get api_v1_nodes_path

      json = JSON.parse(response.body, symbolize_names: true)
      response_data = json[:data]
      response_ids = response_data.map { |node| node[:id].to_i }
      expected_ids = (proposals + nodes).pluck(:id)

      expect(response_data.length).to eql(5)
      expect(response_ids).to match_array(expected_ids)
    end

    it 'can filter out active nodes' do
      get api_v1_nodes_path, params: { "filter[active]": "false" }

      json = JSON.parse(response.body, symbolize_names: true)
      response_data = json[:data]
      response_ids = response_data.map { |node| node[:id].to_i }
      expected_ids = deactivated_proposals.pluck(:id)

      expect(response_data.length).to eql(2)
      expect(response_ids).to match_array(expected_ids)
    end

    it 'can find a deactivated node by id' do
      node = deactivated_proposals.first
      get api_v1_node_path(node), headers: headers

      expect(response).to have_http_status(:ok)
      response_data = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(response_data[:id].to_i).to eq(node.id)
    end
  end

  describe 'creating' do
    let(:user) { create(:user) }
    before(:each) do
      sign_in user

      @root = create(:node, parent_id: nil, name: 'root')
    end

    context 'when creating a node at level 2' do
      it 'creates a collection for the node' do
        params = { data: {
            type: 'nodes',
            attributes: { name: 'Bananas' },
            relationships: { parent: { data: { type: 'nodes', id: @root.id } } },
          }
        }
        expect_any_instance_of(Node).to receive(:set_collection)
        post api_v1_nodes_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:created)
      end
    end
    context 'when creating a node at level 3' do

      before do
        @prog = create(:node, parent_id: @root.id, name: 'prog', owner: user)
      end

      it 'does not create a collection for the node' do
        params = { data: {
            type: 'nodes',
            attributes: { name: 'Bananas' },
            relationships: { parent: { data: { type: 'nodes', id: @prog.id } } },
          }
        }
        expect_any_instance_of(Node).not_to receive(:set_collection)
        post api_v1_nodes_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'updating relationship' do

    let(:user){ create(:user) }
    before(:each) do
      sign_in user
      @root = create(:node, parent_id: nil, name: 'root')
    end

    context 'when moving a node to level 2' do
      before do
        @prog = create(:node, parent_id: @root.id, name: 'prog', owner: user)
        @node = create(:node, parent_id: @prog.id, name: 'node', owner: user)
      end

      it 'creates a collection for the node' do
        params = {
          data: {
            type: 'nodes',
            id: @root.id,
          },
          relationship: 'parent',
          node_id: @node.id,
        }
        expect_any_instance_of(Node).to receive(:set_collection)
        patch api_v1_node_relationships_parent_path(@node), params: params.to_json, headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when moving a node to level 3' do
      before do
        @prog1 = create(:node, parent_id: @root.id, name: 'prog1')
        @prog2 = create(:node, parent_id: @root.id, name: 'prog2', owner: user)
        @node = create(:node, parent_id: @prog1.id, name: 'node', owner: user)
      end

      it 'does not create a collection for the node' do
        params = {
          data: {
            type: 'nodes',
            id: @prog2.id,
          },
          relationship: 'parent',
          node_id: @node.id,
        }
        expect_any_instance_of(Node).not_to receive(:set_collection)
        patch api_v1_node_relationships_parent_path(@node), params: params.to_json, headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'delete' do

    before do
      user = create(:user)
      sign_in user
      @node = create(:node, owner: user)
    end

    it 'deactivates the node' do
      delete api_v1_node_path(@node)
      expect(@node.reload).not_to be_active
    end
  end
end
