require 'rails_helper'

RSpec.describe 'API routing', type: :routing do

  describe 'Program' do

    before(:each) do
      @program = create(:program)
    end

    it 'routes to the index' do
      expect(get: '/api/v1/programs').to be_routable
    end

    it 'routes to show' do
      expect(get: "/api/v1/programs/#{@program.id}").to be_routable
    end

    it 'does not route to updates' do
      expect(patch: "/api/v1/programs/#{@program.id}").to_not be_routable
    end

    it 'does not route to delete' do
      expect(delete: "/api/v1/programs/#{@program.id}").to_not be_routable
    end

    describe 'Relationships' do
      it 'routes to the Projects of a Program' do
        expect(get: "/api/v1/programs/#{@program.id}/projects").to be_routable
      end

      it 'routes to the data about the Projects of a Program' do
        expect(get: "/api/v1/programs/#{@program.id}/relationships/projects").to be_routable
      end
    end

  end

  describe 'Project' do

    before(:each) do
      @project = create(:project)
    end

    it 'routes to the index' do
      expect(get: '/api/v1/projects').to be_routable
    end

    it 'routes to show' do
      expect(get: "/api/v1/projects/#{@project.id}").to be_routable
    end

    it 'does not route to updates' do
      expect(patch: "/api/v1/projects/#{@project.id}").to_not be_routable
    end

    it 'does not route to delete' do
      expect(delete: "/api/v1/projects/#{@project.id}").to_not be_routable
    end

    describe 'Relationships' do
      it 'routes to the Aims of a Project' do
        expect(get: "/api/v1/projects/#{@project.id}/aims").to be_routable
      end

      it 'routes to the data about the Aims of a Project' do
        expect(get: "/api/v1/projects/#{@project.id}/relationships/aims").to be_routable
      end
    end

  end

  describe 'Aim' do

    before(:each) do
      @aim = create(:aim)
    end

    it 'routes to the index' do
      expect(get: '/api/v1/aims').to be_routable
    end

    it 'routes to show' do
      expect(get: "/api/v1/aims/#{@aim.id}").to be_routable
    end

    it 'does not route to updates' do
      expect(patch: "/api/v1/aims/#{@aim.id}").to_not be_routable
    end

    it 'does not route to delete' do
      expect(delete: "/api/v1/aims/#{@aim.id}").to_not be_routable
    end

    describe 'Relationships' do
      it 'routes to the Proposals of an Aim' do
        expect(get: "/api/v1/aims/#{@aim.id}/proposals").to be_routable
      end

      it 'routes to the data about the Proposals of an Aim' do
        expect(get: "/api/v1/aims/#{@aim.id}/relationships/proposals").to be_routable
      end
    end

  end

  describe 'Proposal' do

    before(:each) do
      @proposal = create(:proposal)
    end

    it 'routes to the index' do
      expect(get: '/api/v1/proposals').to be_routable
    end

    it 'routes to show' do
      expect(get: "/api/v1/proposals/#{@proposal.id}").to be_routable
    end

    it 'does not route to updates' do
      expect(patch: "/api/v1/proposals/#{@proposal.id}").to_not be_routable
    end

    it 'does not route to delete' do
      expect(delete: "/api/v1/proposals/#{@proposal.id}").to_not be_routable
    end

  end

  describe 'Collection' do

    before(:each) do
      @collection = create(:collection)
    end

    it 'routes to the index' do
      expect(get: '/api/v1/collections').to be_routable
    end

    it 'routes to show' do
      expect(get: "/api/v1/collections/#{@collection.id}").to be_routable
    end

    it 'does not route to updates' do
      expect(patch: "/api/v1/collections/#{@collection.id}").to_not be_routable
    end

    it 'does not route to delete' do
      expect(delete: "/api/v1/collections/#{@collection.id}").to_not be_routable
    end

  end

end