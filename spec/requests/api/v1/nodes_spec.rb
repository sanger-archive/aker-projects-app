require 'rails_helper'
require 'ostruct'
require 'jwt'

RSpec.describe 'API::V1::Nodes', type: :request do

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

  describe 'GET' do

    before(:each) do
      node = create(:node, cost_code: "S1234", description: "Here is my node", parent: program1)

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
    let!(:proposals) { create_list(:node, 3, cost_code: "S1234", description: "This is a proposal", parent: program1) }
    let!(:nodes) { create_list(:node, 2, parent: program1) }
    let!(:deactivated_proposals) { create_list(:node, 2, deactivated_by: user.email, deactivated_datetime: DateTime.now, cost_code: "S1234", parent: program1) }

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
        subprojects = create_list(:node, 3, 
          cost_code: "S1234/45", description: "This is a subproject", parent: proposals.first) 
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
    before(:each) do

      @prog1 = create(:node, parent_id: program1.id, name: 'Program 1', owner_email: different_user.email)
      @prog2 = create(:node, parent_id: program1.id, name: 'prog2', owner_email: user.email)
    end

    context 'when user does not have write permissions on the parent node (root)' do
      it 'returns 403' do
        params = { data: {
            type: 'nodes',
            attributes: { name: 'Bananas' },
            relationships: { parent: { data: { type: 'nodes', id: root.id } } },
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

    before(:each) do
      @node1 = create(:node, parent_id: program1.id, name: 'node1', owner_email: user.email)
      @node2 = create(:node, parent_id: program1.id, name: 'node2', owner_email: different_user.email)
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

    before(:each) do
      @prog1 = create(:node, parent_id: program1.id, name: 'prog1', owner_email: user.email)
      @prog2 = create(:node, parent_id: program1.id, name: 'prog2', owner_email: different_user.email)
      @prog3 = create(:node, parent_id: program1.id, name: 'prog3', owner_email: user.email)
      @node1 = create(:node, parent_id: @prog1.id, name: 'node1', owner_email: user.email)
    end

    context 'when moving a node to under the root node' do
      it 'returns a 403' do
        params = {
          data: {
            type: 'nodes',
            id: root.id,
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

  describe 'DELETE #remove' do

    before do
      @prog1 = build(:node, parent_id: root.id, name: 'prog1', owner_email: user.email)
      @prog1.save(validate: false)
      @node1 = create(:node, parent_id: @prog1.id, name: 'node1', owner_email: user.email)
      @node2 = create(:node, parent_id: @prog1.id, name: 'node2', owner_email: different_user.email)
    end

    context 'when the node has children' do
      it 'returns a 400 and does not delete the node' do
        delete api_v1_node_path(@prog1), headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(@prog1.reload).to be_active
      end
    end

    context 'when user does not have write permissions on the node' do
      it 'returns a 403 and does not delete the node' do
        delete api_v1_node_path(@node2), headers: headers
        expect(response).to have_http_status(:forbidden)
        expect(@node2.reload).to be_active
      end
    end

    context 'when user does have write permissions on the node' do
      it 'returns a 202 and deletes the node' do
        delete api_v1_node_path(@node1), headers: headers
        expect(response).to have_http_status(:accepted)
        expect(@node1.reload).not_to be_active
      end
    end

  end
end
