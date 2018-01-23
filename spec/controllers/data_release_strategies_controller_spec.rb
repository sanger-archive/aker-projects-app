require 'rails_helper'

RSpec.describe DataReleaseStrategiesController, type: :controller do
  let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }


  context 'DataReleaseStrategies' do
    context '#index' do
      context 'when the user is not logged in' do
        it 'does redirect to the login page' do
          get :index
          expect(response).to have_http_status(:found)
        end
      end
      context 'when the user is logged in' do
        before do
          allow(controller).to receive(:check_credentials)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it 'returns a json with the list of strategies' do
        end
      end    

    end
    context '#show' do
      let(:strategy) { create(:data_release_strategy) }
      context 'when the user is not logged in' do
        it 'does return a forbidden error code' do
          get :show, params: { id: strategy.id }
          expect(response).to have_http_status(:found)
        end
      end
      context 'when the user is logged in' do
        before do
          allow(controller).to receive(:check_credentials)
          allow(controller).to receive(:current_user).and_return(user)
        end

        context 'when the id provided belongs to an existing strategy' do
            before do
              allow(DataReleaseStrategyClient).to(
                receive(:find_strategy_by_uuid)
                  .with(strategy.id)
                  .and_return(strategy)
              )
            end

          it 'returns the info for that strategy' do
            get :show, params: { id: strategy.id }
            expect(response).to have_http_status(:ok)
            expect(response.body).to eq(strategy.to_json)
          end
        end
        context 'when the id provided does not belong to any strategy' do
          it 'returns 404' do
            get :show, params: { id: SecureRandom.uuid }
            expect(response).to have_http_status(:not_found)
          end
        end
      end
    end
  end
end