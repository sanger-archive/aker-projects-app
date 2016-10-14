require 'rails_helper'

RSpec.describe 'API::V1::Proposals' do

  describe 'GET' do
    before(:each) do
      proposal = create(:proposal)

      get api_v1_proposal_path(proposal), headers: {
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

    it 'conforms to the Proposal schema' do
      expect(response).to match_api_schema('proposal')
    end
  end
end