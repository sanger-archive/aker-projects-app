require 'rails_helper'

RSpec.describe 'Api::V1::Collections', type: :request do

  describe 'GET' do

    before(:each) do
      expect(SetClient::Set).to receive(:create).and_return(double('Set', id: SecureRandom.uuid))
      collection = create(:collection, set_id: nil)

      get api_v1_collection_path(collection), headers: {
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

    it 'conforms to the Collection schema'
  end
end