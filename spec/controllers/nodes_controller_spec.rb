require 'rails_helper'

RSpec.describe NodesController, type: :controller do

  let(:user) { create(:user) }

  setup do
    sign_in user

    @root = create(:node, name: "root", parent_id: nil)
  end

  describe 'DELETE #destroy' do
    setup do
      @program1 = create(:node, name: "program1", parent: @root, owner: user)
    end

    context "success" do
      it "deletes the node" do
        delete :destroy, params: { id: @program1}
        expect(@program1.reload).not_to be_active
        expect(flash[:success]).to match('Node deleted')
      end
    end

    context "failure" do
      before do
        @program11 = create(:node, name: "program11", parent: @program1)
      end

      it "you cannot delete a node with children" do
        delete :destroy, params: { id: @program1 }
        expect(@program1.reload).to be_active
        expect(flash[:danger]).to match('A node with active children cannot be deactivated')
      end
    end
  end

  describe 'CREATE #create' do
    context "node at level 2" do
      it "should create a collection" do
        expect_any_instance_of(Node).to receive(:set_collection)
        post :create, params: { node: { parent_id: @root.id, name: "Bananas" } }
      end
    end
    context "node at level 3" do
      before do
        @prog = create(:node, name: "prog", parent: @root)
      end
      it "should not create a collection" do
        expect_any_instance_of(Node).not_to receive(:set_collection)
        post :create, params: { node: { parent_id: @prog.id, name: "Bananas" } }
      end
    end
    describe 'owner' do
      it "should set the owner" do
        allow_any_instance_of(Node).to receive(:set_collection)

        parent = create(:node, owner: user)

        post :create, params: { node: { parent_id: parent.id, name: "Bananas" } }

        n = Node.find_by(name: "Bananas")
        expect(n).not_to be_nil
        expect(n.owner).not_to be_nil
        expect(n.owner).to eq(user)
      end
    end
  end

  describe 'EDIT #update' do
    setup do
      @program1 = create(:node, name: "program1", parent: @root)
    end

    context "success" do
      it "update the node" do
        put :update, params: { id: @program1.id, node: { id: @program1.id, name: "test"} }
        @program1.reload
        @program1.name == "test"
      end
    end
  end

end
