class TreeLayoutsController < ApplicationController
  skip_authorization_check

  def create
    @tree_layout = TreeLayout.find_by(user_id: current_user.email)
    data = {
      user_id: current_user.email, 
      layout: tree_layout_params[:layout]
    }
    
    if @tree_layout
      @tree_layout.update_attributes!(data)
    else
      @tree_layout = TreeLayout.create!(data)
    end
    
    render json: json_for_tree_layout(@tree_layout)
  end

  def index
    @tree_layouts = [TreeLayout.find_by(user_id: current_user.email)].flatten.compact

    if @tree_layouts.length > 0
      @tree_layout = @tree_layouts.first
    else
      @tree_layout = nil
    end
    render json: [json_for_tree_layout(@tree_layout)].compact
  end

  def destroy
    TreeLayout.where(user_id: current_user.email).each(&:destroy)

    render json: {}
  end

  private

  def json_for_tree_layout(tree_layout)
    return nil unless tree_layout
    {tree_layout:  tree_layout.as_json(only: [:layout, :created_at, :updated_at]) }
  end

  def tree_layout_params
    params.require(:tree_layout).permit(:layout)
  end
end
