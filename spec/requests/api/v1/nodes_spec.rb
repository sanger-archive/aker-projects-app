require 'rails_helper'

RSpec.describe 'API::V1::Nodes', type: :request do

  describe 'GET' do
    before(:each) do
      user = create(:user)
      sign_in user        

      node = create(:node, cost_code: "S1234", description: "Here is my node")

      get api_v1_node_path(node), headers: {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
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

        get api_v1_nodes_path, params: { "filter[cost_code]": "_none" }, headers: {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        }

        @json = JSON.parse(response.body, symbolize_names: true)
      end

      it 'returns only the nodes without a cost code' do
        expect(@json[:data].length).to eql(2)
      end

    end

    context 'when using a value of !_none for cost_code' do

      before(:each) do
        get api_v1_nodes_path, params: { "filter[cost_code]": "!_none" }, headers: {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        }

        @json = JSON.parse(response.body, symbolize_names: true)
      end

      it 'returns on the nodes with a cost code' do
        expect(@json[:data].length).to eql(3)
      end

    end


  end
end