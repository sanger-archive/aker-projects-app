require 'rails_helper'

RSpec.describe 'API::V1::Nodes', type: :request do

  describe 'GET' do
    before(:each) do
      node = create(:node)

      get api_v1_node_path(node), headers: {
        "Content-Type": "application/vnd.api+json",
        "Accept": "application/vnd.api+json"
      }
    end

    it 'returns a response of ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'comforms to the JSON API schema' do
      expect(response).to match_api_schema('jsonapi')
    end

    it 'comforms to the Nodes schema' do
      expect(response).to match_api_schema('node')
    end
  end
end