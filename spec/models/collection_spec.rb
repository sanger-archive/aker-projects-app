require 'rails_helper'

# class FakeSet
#   include ActiveModel::Model

#   attr_accessor :id, :name

#   def update_attributes(attrs)
#     assign_attributes(attrs)
#   end
# end

RSpec.describe Collection, type: :model do
  describe '#validate set uuid' do
    before do
      @root = build(:node, name: 'root', parent_id: nil)
      @root.save!(validate: false)
      @program = build(:node, name: 'program', parent: @root)
      @program.save!(validate: false)
    end
    it 'is valid with a uuid for set id' do
      expect(build(:collection, set_id: SecureRandom.uuid, collector: @program)).to be_valid
    end
    it 'is not valid with something weird for set id' do
      expect(build(:collection, set_id: 'XXX', collector: @program)).not_to be_valid
    end
    it 'is not valid with a blank set id' do
      expect(build(:collection, set_id: '', collector: @program)).not_to be_valid
    end
  end


  # context '#destroy' do
  #   setup do
  #     @root = build(:node, name: 'root', parent_id: nil)
  #     @root.save!(validate: false)
  #     @program = build(:node, name: 'program', parent: @root)
  #     @program.save!(validate: false)
  #     @collection = create(:collection, set_id: SecureRandom.uuid, collector: @program)
  #     @set = FakeSet.new(name: 'SOME NAME')
  #   end

  #   it 'nullifies the set name before destroy' do
  #     expect(SetClient::Set).to receive(:find).with(@collection.set_id).and_return([@set]).at_least(:once)
  #     expect(@collection.set_nullified?).to eq(false)
  #     @collection.destroy
  #     expect(@collection.set_nullified?).to eq(true)
  #   end
  # end

  # describe '#create' do
  #   before do
  #     @root = build(:node, name: 'root', parent_id: nil)
  #     @root.save!(validate: false)
  #     @program = build(:node, name: 'program', parent: @root)
  #     @program.save!(validate: false)
  #     @set_uuid = SecureRandom.uuid
  #     @collection = create(:collection, set_id: @set_uuid, collector: @program)
  #     @set = FakeSet.new(name: @collection.collector.name, id: @set_uuid)
  #   end

  #   it 'creates a Set through the SetClient' do
  #     expect(SetClient::Set).to receive(:create)
  #       .with(name: @collection.collector.name)
  #       .and_return(@set)

  #     @collection.save

  #     expect(@collection.set_id).to eq(@set_uuid)
  #   end
  # end
end