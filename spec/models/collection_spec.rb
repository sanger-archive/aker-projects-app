require 'rails_helper'

class FakeSet
  include ActiveModel::Model

  attr_accessor :name

  def update_attributes(attrs)
    assign_attributes(attrs)
  end
end

RSpec.describe Collection, type: :model do
  context '#destroy' do
    setup do
      @collection = create :collection, :set_id => SecureRandom.uuid
      @set = FakeSet.new(name: 'SOME NAME')
    end

    it 'nullifies the set name before destroy' do
      expect(SetClient::Set).to receive(:find).with(@collection.set_id).and_return(@set).at_least(:once)
      expect(@collection.set_nullified?).to eq(false)
      @collection.destroy
      expect(@collection.set_nullified?).to eq(true)
    end
  end
end