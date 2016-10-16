require 'rails_helper'

RSpec.feature "Proposals", type: :feature do

  let(:proposal) { create(:proposal) }

  context 'when I visit a Proposal page' do

    before do
      visit proposal_path(proposal)
    end

    it 'will display the Proposal name' do
      expect(page).to have_content(proposal.name)
    end

  end
end
