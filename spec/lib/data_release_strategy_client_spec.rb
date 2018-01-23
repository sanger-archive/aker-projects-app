require 'rails_helper'

RSpec.describe DataReleaseStrategyClient do
  context '#find_strategies_by_user' do
    let(:user) { double('user', email: 'some@email') } 
    let(:connection) {double('connection')}
    let(:response) { double('response')}
    let(:response_obj) {
      { 
        data: data_list
      }.to_json
    }
    before do
      allow(response).to receive(:body).and_return(response_obj)
      allow(DataReleaseStrategyClient).to receive(:get_connection).and_return(connection)
      allow(connection).to receive(:get).and_return(response)
    end
    context 'when the user does not have any strategies' do
      let(:data_list) { [] }
      it 'returns an empty list' do
        expect(DataReleaseStrategyClient.find_strategies_by_user(user.email)).to eq([])
      end
    end
    context 'when the strategies of the user do not exist' do
      let(:data_list) { [{attributes: {uuid: SecureRandom.uuid, name: 'a new strategy' }}] }
      it 'creates the strategies' do
        count = DataReleaseStrategy.all.count
        list = DataReleaseStrategyClient.find_strategies_by_user(user.email)
        expect(list.count).to eq(data_list.count)
        expect(DataReleaseStrategy.all.count).to eq(count+data_list.count)
      end
      it 'sets the same values for the attributes in local' do
        list = DataReleaseStrategyClient.find_strategies_by_user(user.email)
        list.each do |s|
          expect(s.class).to eq(DataReleaseStrategy)
          obtained = data_list.select{|obj| obj[:attributes][:uuid] == s.id }
          expect(obtained.count).to eq(1)
          expect(obtained.first[:attributes][:name]).to eq(s.name)
        end        
      end
    end
    context 'when the strategies do exist' do
      let(:strategy) { create :data_release_strategy }
      let(:data_list) { [{attributes: {uuid: strategy.id, name: strategy.name }}] }
      it 'does not create any new strategies' do
        count = DataReleaseStrategy.all.count
        list = DataReleaseStrategyClient.find_strategies_by_user(user.email)
        expect(DataReleaseStrategy.all.count).to eq(count)
      end
      context 'when a strategy has a different name' do
        let(:data_list) { [{attributes: {uuid: strategy.id, name: 'a different name'}}] }
        it 'updates its content' do
          list = DataReleaseStrategyClient.find_strategies_by_user(user.email)
          expect(DataReleaseStrategy.find_by(id: strategy.id).name).to eq('a different name')
        end
      end
    end
  end

  context '#find_strategy_by_uuid' do
    let(:strategy) { create :data_release_strategy }
    it 'returns the data release strategy with that uuid' do
      expect(DataReleaseStrategyClient.find_strategy_by_uuid(strategy.id)).to eq(strategy)
    end
  end

  context '::DataReleaseStrategyValidator' do
    context 'when I have a model that uses this validator to validate data_release_strategy_id' do
      let(:model_class) {
        class SomeClass
          attr_accessor :data_release_strategy_id, :current_user
          include ActiveModel::Validations
          validates_with DataReleaseStrategyClient::DataReleaseStrategyValidator
        end
        SomeClass
      }
      let(:user) { double('user', email: 'some@email') } 
      context '#valid?' do
        let(:model) {
          obj = model_class.new
          obj.data_release_strategy_id = strategy_id
          obj.current_user = user
          obj
        }
        let(:strategy) { create :data_release_strategy }
        let(:strategy_id) { strategy.id } 

        context 'when id is not an UUID' do
          let(:strategy_id) { 'some random text' } 
          it 'is not valid' do
            expect(model.valid?).to eq(false)
          end
          it 'gives an error about the UUID' do
            model.valid?
            expect(model.errors[:data_release_strategy_id].first).to include('UUID')
          end
        end
        context 'when there is no connection with the service' do
          before do
            allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).and_raise(Faraday::ConnectionFailed, 'not good')
          end
          it 'is not valid' do
            expect(model.valid?).to eq(false)
          end        
          it 'gives an error about the external service' do
            model.valid?
            expect(model.errors[:data_release_strategy_id].first).to include('connection')
          end 
        end
        context 'when the data release id is not in the list for the user' do
          before do
            allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).with(user.email).and_return([])
          end
          it 'is not valid' do
            expect(model.valid?).to eq(false)
          end
          it 'gives an error about this' do
            model.valid?
            expect(model.errors[:data_release_strategy_id].first).to include('user cannot select')
          end
        end
        context 'when the data release id is in the list' do
          before do
            allow(DataReleaseStrategyClient).to receive(:find_strategies_by_user).with(user.email).and_return([strategy])
          end

          it 'is valid' do
            expect(model.valid?).to eq(true)
          end
        end
      end    
    end
  end
end