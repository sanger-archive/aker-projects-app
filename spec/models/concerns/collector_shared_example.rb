require 'spec_helper'

RSpec.shared_examples_for 'collector' do

  # The class that has included the collector concern
  let(:model) { described_class }

  context 'On create' do
    it 'creates a Collection' do
      expect(create(model.to_s.underscore.to_sym).collection).to be_kind_of Collection
    end
  end

end