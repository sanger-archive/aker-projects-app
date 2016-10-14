require 'rails_helper'

RSpec.describe 'Api::V1::Aims', type: :request do

  describe 'GET' do

    before(:each) do
      aim = create(:aim)

      get api_v1_aim_path(aim), headers: {
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

    it 'comforms to the Aim schema' do
      expect(response).to match_api_schema('aim')
    end
  end
end