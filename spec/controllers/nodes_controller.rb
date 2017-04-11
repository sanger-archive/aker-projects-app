require 'rails_helper'

RSpec.describe NodesController, type: :controller do

  setup do
    user = create(:user)
    sign_in user    
  end

  describe 'DELETE #destroy' do
    setup do
      @root = create(:node, name: "root", parent_id: nil)
      @program1 = create(:node, name: "program1", parent: @root)
    end

    context "success" do
      it "deletes the node" do
        expect { delete :destroy, :id => @program1 }.to change(Node, :count).by(-1)
        expect(flash[:success]).to match('Node deleted')
      end
    end

    context "failure" do
      before do
        @program11 = create(:node, name: "program11", parent: @program1)
      end

      it "you cannot delete a node with children" do
        expect { delete :destroy, :id => @program1 }.to change(Node, :count).by(0)
        expect(flash[:danger]).to match('A node with children cannot be deleted')
      end
    end

  end

  describe 'EDIT #update' do
    setup do
      @root = create(:node, name: "root", parent_id: nil)
      @program1 = create(:node, name: "program1", parent: @root)
    end

    context "success" do
      it "update the node" do
        put :update, id: @program1.id, node: {:id=> @program1.id, :name=>"test"}
        @program1.reload
        @program1.name == "test"
      end
    end

  end

end
