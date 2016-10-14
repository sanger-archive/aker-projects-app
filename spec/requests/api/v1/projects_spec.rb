require 'rails_helper'

RSpec.describe 'API::V1::Projects', type: :request do

  describe 'GET' do
    before(:each) do
      project = create(:project)

      get api_v1_project_path(project), headers: {
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

    it 'comforms to the Project schema' do
      expect(response).to match_api_schema('project')
    end
  end
end