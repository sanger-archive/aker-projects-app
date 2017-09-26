require 'rails_helper'

RSpec.describe 'API routing', type: :routing do

  let(:root) {
    n = build(:node, name: 'root')
    n.save(validate: false)
    n
  }

  let(:program1) {
    n = build(:node, name: 'program1', parent: root, owner_email: 'user@sanger.ac.uk')
    n.save(validate: false)
    n
  }

  describe 'Node' do

    before(:each) do
      @node = create(:node, parent: program1)
    end

    it 'routes to the index' do
      expect(get: '/api/v1/nodes').to be_routable
    end

    it 'routes to show' do
      expect(get: "/api/v1/nodes/#{@node.id}").to be_routable
    end

    it 'does not route to updates' do
      expect(patch: "/api/v1/nodes/#{@node.id}").to be_routable
    end

    it 'does not route to delete' do
      expect(delete: "/api/v1/nodes/#{@node.id}").to be_routable
    end

    describe 'Relationships' do
      it 'routes to the child nodes of a node' do
        expect(get: "/api/v1/nodes/#{@node.id}/nodes").to be_routable
      end

      it 'routes to the data about the child nodes of a node' do
        expect(get: "/api/v1/nodes/#{@node.id}/relationships/nodes").to be_routable
      end

      it 'routes to the parent of a node' do
        expect(get: "/api/v1/nodes/#{@node.id}/parent").to be_routable
      end
    end

  end

end
