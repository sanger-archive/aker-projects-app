require 'rails_helper'

RSpec.describe 'Api::V1::Programs', type: :request do

  describe 'GET' do
    before(:each) do
      program = create(:program)

      get api_v1_program_path(program), headers: {
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

    it 'comforms to the Program schema' do
      expect(response).to match_api_schema('program')
    end
  end

end