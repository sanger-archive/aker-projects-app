require 'rails_helper'

def make_tree_layout_params
  {tree_layout: { layout: "[1,2,3]" } }
end

def make_tree_layout(user)
  create :tree_layout, user_id: user.email, layout: "[1,2,3]"
end

RSpec.describe TreeLayoutsController, type: :controller do
  context '#create' do
    context 'when there is a user logged in' do
      setup do
        @user = OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world'])
        allow(controller).to receive(:check_credentials)
        allow(controller).to receive(:current_user).and_return(@user)
      end

      context 'with no layout stored yet' do
        it 'creates a new tree layout for the user' do
          val = TreeLayout.all.count
          post :create, params: make_tree_layout_params
          expect(TreeLayout.all.count).to eq(val+1)
        end
      end
      context 'with a previously stored tree layout' do
        setup do
          @tree_layout = make_tree_layout(@user)
        end
        it 'does not create a new tree layout' do
          val = TreeLayout.all.count
          post :create, params: make_tree_layout_params
          expect(TreeLayout.all.count).to eq(val)
        end
        it 'updates the old tree layout with the new one' do
          val = TreeLayout.all.count
          post :create, params: make_tree_layout_params
          expect(TreeLayout.all.count).to eq(val)
        end
      end
    end
    context 'when there is no user authenticated' do
      it 'does not create anything' do
        post :create, params: make_tree_layout_params
        expect(TreeLayout.all.count).to eq(0)
      end
      it 'redirects to the login page' do
        post :create, params: make_tree_layout_params
        expect(response).to have_http_status(:redirect)
      end
    end
  end
  context '#index' do
    context 'when there is no user authenticated' do
      it 'redirects to the login page' do
        get :index
        expect(response).to have_http_status(:redirect)        
      end
    end
    context 'when there is a user logged in' do
      setup do
        @user = OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world'])
        allow(controller).to receive(:check_credentials)
        allow(controller).to receive(:current_user).and_return(@user)        
      end
      context 'when the user has no layout stored yet' do
        setup do
          @user2=OpenStruct.new(email: 'user2@sanger.ac.uk', groups: ['world'])
          @tree_layout = make_tree_layout(@user2)
        end
        it 'returns an empty tree layout' do
          get :index
          expect(JSON.parse(response.body)).to eq([])
        end
      end
      context 'when the user has a stored tree layout' do
        setup do
          @tree_layout = make_tree_layout(@user)
        end

        it 'returns the previously stored tree layout' do
          get :index
          json = JSON.parse(response.body, symbolize_names: true)
          expect(json.first[:tree_layout][:layout]).to eq(@tree_layout.layout)          
        end
      end
    end
  end
  context '#destroy' do
    context 'when there is no user authenticated' do
      it 'redirects to the login page' do
        delete :destroy
        expect(response).to have_http_status(:redirect)        
      end
    end
    context 'when there is a user logged in' do
      setup do
        @user = OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world'])
        allow(controller).to receive(:check_credentials)
        allow(controller).to receive(:current_user).and_return(@user)        
      end

      context 'when the user has no layout stored yet' do
        it 'does nothing' do
          val = TreeLayout.all.count
          delete :destroy
          expect(TreeLayout.all.count).to eq(val)
        end
      end
      context 'when the user has a stored tree layout' do
        setup do
          @tree_layout = make_tree_layout(@user)
        end

        it 'destroys the tree layout' do
          val = TreeLayout.all.count
          delete :destroy
          expect(TreeLayout.all.count).to eq(val-1)
        end

        context 'when the tree layout has been destroyed' do
          setup do
            delete :destroy
          end

          context 'when the user creates a new tree layout' do
            setup do
              @other_layout = "other layout"
              post :create, {tree_layout: { layout: @other_layout } }
            end
            it 'creates the new tree layout' do
              layouts = TreeLayout.find_by(user_id: @user.email)
              expect(layouts.layout).to eq(@other_layout)
            end
            it 'shows the new tree layout' do
              get :index
              json = JSON.parse(response.body, symbolize_names: true)
              expect(json.first[:tree_layout][:layout]).to eq(@other_layout)          
            end
          end
          context 'when the user shows the tree layout' do
            it 'returns an empty tree layout' do
              get :index
              json = JSON.parse(response.body, symbolize_names: true)
              expect(json).to eq([])
            end
          end
        end
      end
    end    
  end
end