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

    context "when a user does not have write permission on the node" do
      let(:different_user) { create(:user) }
      before do
        @program2 = create(:node, name: "program2", parent: @program1, owner: different_user)
      end

      it "should not delete the node" do
        expect { delete :destroy, params: { id: @program2 } }.to change{Node.all.count}.by(0)
      end
    end

    context "when a user does have write permission on the node" do
      before do
        @program3 = create(:node, name: "program3", parent: @program1, owner: user)
      end

      it "should delete the node" do
        delete :destroy, params: { id: @program3 }
        expect(@program3.reload).not_to be_active
        expect(flash[:success]).to match('Node deleted')
      end

      it "should not delete a node with children" do
        delete :destroy, params: { id: @program1 }
        expect(@program1.reload).to be_active
        expect(flash[:danger]).to match('A node with active children cannot be deactivated')
      end
    end
  end

  describe 'CREATE #create' do

    context "when a user does not have write permission on the parent node" do
      it "should not create a new node" do
        expect { post :create, params: { node: { parent_id: @root.id, name: "Bananas" } } }.to change{Node.all.count}.by(0)
      end
    end

    context "when a user does have write permission on the parent node" do
      before do
        @prog = create(:node, name: "prog", parent: @root, owner: user)
      end
      it "should create a new node" do
        expect { post :create, params: { node: { parent_id: @prog.id, name: "Bananas" } } }.to change{Node.all.count}.by(1)
      end
    end

    describe 'owner' do
      it "should set the owner" do
        parent = create(:node, name: "parent", parent: @root, owner: user)
        post :create, params: { node: { parent_id: parent.id, name: "Bananas" } }

        n = Node.find_by(name: "Bananas")
        expect(n).not_to be_nil
        expect(n.owner).not_to be_nil
        expect(n.owner).to eq(user)
      end
    end
  end

  describe 'EDIT #update' do

    let(:different_user) { create(:user) }

    setup do
      @program1 = create(:node, name: "program1", parent: @root, owner: user)
      @program2 = create(:node, name: "program2", parent: @root, owner: different_user)
    end

    context "when a user does have write permissions on the node" do
      it "should update the node" do
        put :update, params: { id: @program1.id, node: { id: @program1.id, name: "test"} }
        @program1.reload
        expect(@program1.name).to eq "test"
      end
    end

    context "when a user does not have write permissions on the node" do
      it "should not update the node" do
        put :update, params: { id: @program2.id, node: { id: @program2.id, name: "test"} }
        @program2.reload
        expect(@program2.name).to eq "program2"
      end
    end

  end

end
