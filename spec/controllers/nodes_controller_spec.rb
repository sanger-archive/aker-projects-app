require 'rails_helper'

RSpec.describe NodesController, type: :controller do

  let(:user) { create(:user) }

  let(:root) {
    n = build(:node, name: 'root')
    n.save(validate: false)
    n
  }

  let(:program1) {
    n = build(:node, name: 'program1', parent: root, owner: user)
    n.save(validate: false)
    n
  }

  setup do
    sign_in user
  end

  describe 'DELETE #destroy' do

    context "when a user does not have write permission on the node" do
      let(:different_user) { create(:user) }
      before do
        @program2 = create(:node, name: "program2", parent: program1, owner: different_user)
      end

      it "should not delete the node" do
        expect { delete :destroy, params: { id: @program2 } }.to change{Node.all.count}.by(0)
      end
    end

    context "when a user does have write permission on the node" do
      before do
        @program3 = create(:node, name: "program3", parent: program1, owner: user)
      end

      it "should delete the node" do
        delete :destroy, params: { id: @program3 }
        expect(@program3.reload).not_to be_active
        expect(flash[:success]).to match('Node deleted')
      end

      it "should not delete a node with children" do
        @program4 = create(:node, name: "program4", parent: @program3, owner: user)
        delete :destroy, params: { id: @program3 }
        expect(@program3.reload).to be_active
        expect(flash[:danger]).to match('A node with active children cannot be deactivated')
      end
    end
  end

  describe 'CREATE #create' do
    let(:different_user) { create(:user) }
    setup do
      @program2 = create(:node, name: "program2", parent: program1, owner: different_user)
    end

    context "when the parent is the root node" do
      it "should not create a new node" do
        expect { post :create, params: { node_form: { parent_id: root.id, name: "Bananas" } } }.to change{Node.all.count}.by(0)
      end
    end

    context 'when permissions are specified' do
      before do
        @prog = create(:node, name: "prog", parent: program1, owner: user)
      end
      it "should create a new node" do
        expect { post :create, params: { node_form: { parent_id: @prog.id, name: "Bananas", user_writers: 'dirk,jeff@sanger.ac.uk', group_writers: 'team_gamma,team_DELTA', user_spenders: 'DIRK@sanger.ac.uk', group_spenders: 'team_delta,team_epsilon' } } }.to change{Node.all.count}.by(1)
        node = Node.find_by(name: "Bananas")
        expect(node).not_to be_nil
        expect(node.permitted?('dirk@sanger.ac.uk', :write)).to be_truthy
        expect(node.permitted?('dirk@sanger.ac.uk', :spend)).to be_truthy
        expect(node.permitted?('jeff@sanger.ac.uk', :write)).to be_truthy
        expect(node.permitted?('jeff@sanger.ac.uk', :spend)).to be_falsey
        expect(node.permitted?('world', :read)).to be_truthy
        expect(node.permitted?('world', :write)).to be_falsey
        expect(node.permitted?('team_delta', :write)).to be_truthy
        expect(node.permitted?('team_delta', :spend)).to be_truthy
        expect(node.permitted?('team_gamma', :write)).to be_truthy
        expect(node.permitted?('team_gamma', :spend)).to be_falsey
        expect(node.permitted?(user.email, :read)).to be_truthy
        expect(node.permitted?(user.email, :write)).to be_truthy
        expect(node.permitted?(user.email, :spend)).to be_truthy
      end
    end

    context "when a user does not have write permission on the parent node" do
      it "should not create a new node" do
        expect { post :create, params: { node_form: { parent_id: @program2.id, name: "Bananas" } } }.to change{Node.all.count}.by(0)
      end
    end

    context "when a user does have write permission on the parent node" do
      before do
        @prog = create(:node, name: "prog", parent: program1, owner: user)
      end
      it "should create a new node" do
        expect { post :create, params: { node_form: { parent_id: @prog.id, name: "Bananas" } } }.to change{Node.all.count}.by(1)
      end
    end

    describe 'owner' do
      it "should set the owner" do
        parent = create(:node, name: "parent", parent: program1, owner: user)
        post :create, params: { node_form: { parent_id: parent.id, name: "Bananas" } }

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
      @program2 = create(:node, name: "program2", parent: program1, owner: different_user)
      @program3 = create(:node, name: "program3", parent: program1, owner: user)
    end

    context "when a user does have write permissions on the node" do
      it "should update the node" do
        put :update, params: { id: @program3.id, node_form: { id: @program3.id, name: "test", parent_id: program1.id } }
        @program3.reload
        expect(@program3.name).to eq "test"
      end
    end

    context "when a user does not have write permissions on the node" do
      it "should not update the node" do
        put :update, params: { id: @program2.id, node_form: { id: @program2.id, name: "test", parent_id: program1.id } }
        @program2.reload
        expect(@program2.name).to eq "program2"
      end
    end

  end

end
