class NodesController < ApplicationController

  include AkerAuthenticationGem::AuthController
  include AkerPermissionControllerConfig

  skip_authorization_check only: :show

  before_action :current_node, except: :create
  before_action :set_child, only: [:show, :list, :tree]

  def show
    render "list"
  end

  def index
    render "list"
  end

  def list
  end

  def tree
  end

  def create
    @node = Node.new(node_params)

    if @node.save
      flash[:success] = "Node created"
    else
      flash[:danger] = "Failed to create node"
    end
    redirect_to node_path(@node.parent_id)
  end

  def edit
    respond_to do |format|
      format.html
      format.js { render template: 'nodes/modal' }
    end
  end

  def update
    respond_to do |format|
      if @node.update_attributes(node_params)
        format.html { redirect_to node_path(@node.parent_id), flash: { success: "Node updated" }}
        format.json { render json: @node, status: :ok }
      else
        format.html { redirect_to edit_node_path(@node.id), flash: { danger: "Failed to update node" }}
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @parent_id = @node.parent_id

    if @node.destroy
      flash[:success] = "Node deleted"
      redirect_to node_path(@parent_id)
    else
      flash[:danger] = "A node with children cannot be deleted"
      redirect_to node_path(@parent_id)
    end
  end

  private

  def set_child
    @child = Node.new(parent: @node)
  end

  def current_node
    @node = params[:id] ? Node.find(params[:id]) : Node.root
  end

  def node_params
    params.require(:node).permit(:name, :parent_id, :description, :cost_code)
  end

end
