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
      user = create(:user)
      sign_in user
    end

    let!(:proposals) { create_list(:node, 3, cost_code: "S1234", description: "This is a proposal") }
    let!(:nodes) { create_list(:node, 2) }

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
        expect(@json[:data].length).to eql(3)
      end
    end
  end

  describe 'creating' do
    before(:each) do
      user = create(:user)
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
        @prog = create(:node, parent_id: @root.id, name: 'prog')
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
    before(:each) do
      user = create(:user)
      sign_in user
      @root = create(:node, parent_id: nil, name: 'root')
    end

    context 'when moving a node to level 2' do
      before do
        @prog = create(:node, parent_id: @root.id, name: 'prog')
        @node = create(:node, parent_id: @prog.id, name: 'node')
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
        @prog2 = create(:node, parent_id: @root.id, name: 'prog2')
        @node = create(:node, parent_id: @prog1.id, name: 'node')
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
end
