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

  describe 'CREATE #create' do
    let(:user) { create(:user) }
    before(:each) do
      sign_in user

      @root = create(:node, parent_id: nil, name: 'root')
      @prog1 = create(:node, parent_id: @root.id, name: 'Program 1')
      @prog2 = create(:node, parent_id: @root.id, name: 'prog2', owner: user)
    end

    context 'when user does not have write permissions on the parent node (root)' do
      it 'returns 403' do
        params = { data: {
            type: 'nodes',
            attributes: { name: 'Bananas' },
            relationships: { parent: { data: { type: 'nodes', id: @root.id } } },
          }
        }
        post api_v1_nodes_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user does not have write permissions on the parent node' do
      it 'returns 403' do
        params = { data: {
            type: 'nodes',
            attributes: { name: 'Cherries' },
            relationships: { parent: { data: { type: 'nodes', id: @prog1.id } } },
          }
        }
        post api_v1_nodes_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user does have write permissions on the parent node' do
      it 'returns 201' do
        params = { data: {
            type: 'nodes',
            attributes: { name: 'Bananas' },
            relationships: { parent: { data: { type: 'nodes', id: @prog2.id } } },
          }
        }
        post api_v1_nodes_path, params: params.to_json, headers: headers
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'UPDATE #update' do

    let(:user){ create(:user) }
    let(:different_user) { create(:user) }

    before(:each) do
      sign_in user

      @root = create(:node, parent_id: nil, name: 'root')
      @prog1 = create(:node, parent_id: @root.id, name: 'prog1', owner: different_user)
      @node1 = create(:node, parent_id: @prog1.id, name: 'node1', owner: user)
      @node2 = create(:node, parent_id: @prog1.id, name: 'node2', owner: different_user)
    end

    context 'when user does not have write permissions on the node' do
      it 'returns a 403' do
        params = { data: {
            id: @node2.id,
            type: 'nodes',
            attributes: { name: 'Bananas' }
          }
        }

        patch api_v1_node_path(@node2), params: params.to_json, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user does have write permissions on the node' do
      it 'returns a 200' do
        params = { data: {
            id: @node1.id,
            type: 'nodes',
            attributes: { name: 'Strawberries' }
          }
        }
        patch api_v1_node_path(@node1), params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'UPDATE #update_relationship' do

    let(:user){ create(:user) }
    let(:different_user){ create(:user) }
    before(:each) do
      sign_in user
      @root = create(:node, parent_id: nil, name: 'root')
      @prog1 = create(:node, parent_id: @root.id, name: 'prog1', owner: user)
      @prog2 = create(:node, parent_id: @root.id, name: 'prog2', owner: different_user)
      @prog3 = create(:node, parent_id: @root.id, name: 'prog3', owner: user)
      @node1 = create(:node, parent_id: @prog1.id, name: 'node1', owner: user)
    end

    context 'when moving a node to under the root node' do
      it 'returns a 403' do
        params = {
          data: {
            type: 'nodes',
            id: @root.id,
          },
          relationship: 'parent',
          node_id: @node1.id,
        }
        patch api_v1_node_relationships_parent_path(@node1), params: params.to_json, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user does not have write permissions on the destination parent node' do
      it 'does not update the relationship' do
        params = {
          data: {
            type: 'nodes',
            id: @prog2.id,
          },
          relationship: 'parent',
          node_id: @node1.id,
        }
        patch api_v1_node_relationships_parent_path(@node1), params: params.to_json, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when user does have write permissions on the destination parent node' do
      it 'successfully updates relationship' do
        params = {
          data: {
            type: 'nodes',
            id: @prog1.id,
          },
          relationship: 'parent',
          node_id: @node1.id,
        }
        patch api_v1_node_relationships_parent_path(@node1), params: params.to_json, headers: headers
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user){ create(:user) }
    let(:different_user) { create(:user) }

    before do
      sign_in user
      @root = create(:node, parent_id: nil, name: 'root')
      @prog1 = create(:node, parent_id: @root.id, name: 'prog1', owner: user)
      @node1 = create(:node, parent_id: @prog1.id, name: 'node1', owner: user)
      @node2 = create(:node, parent_id: @prog1.id, name: 'node2', owner: different_user)
    end

    context 'when the node is under the root node' do
      it 'returns a 403' do
        delete api_v1_node_path(@prog1)
        expect(@prog1.reload).to be_active
      end
    end

    context 'when user does not have write permissions on the node' do
      it 'returns a 403' do
        delete api_v1_node_path(@node2)
        expect(@node2.reload).to be_active
      end
    end

    context 'when user does have write permissions on the node' do
      it 'returns a 202' do
        delete api_v1_node_path(@node1)
        expect(@node1.reload).not_to be_active
      end
    end

  end
end
