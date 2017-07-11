class NodesController < ApplicationController

  include AkerAuthenticationGem::AuthController
  include AkerPermissionControllerConfig

  before_action :current_node, except: :create
  before_action :set_child, only: [:show, :list, :tree]

  def show
    authorize! :read, Node
    render "list"
  end

  def index
    render "list"
  end

  def list
    authorize! :read, Node
  end

  def tree
    authorize! :read, Node
  end

  def create
    authorize! :create, Node, message: 'You are not authorized to create this node.'
    # You must have write permission on the parent node to create
    # Everyone is allowed to create a node under root
    authorize! :write, parent_node

    @node = Node.new(node_params)

    @node.owner = current_user

    if @node.save
      flash[:success] = "Node created"
    else
      flash[:danger] = "Failed to create node"
    end
    redirect_to node_path(@node.parent_id)
  end

  def edit
    authorize! :read, current_node

    respond_to do |format|
      format.html
      format.js { render template: 'nodes/modal' }
    end
  end

  def update
    authorize! :write, current_node

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
    authorize! :write, current_node, message: 'You are not authorized to delete this node.'

    @parent_id = @node.parent_id

    if @node.deactivate(current_user)
      flash[:success] = "Node deleted"
      redirect_to node_path(@parent_id)
    else
      flash[:danger] = @node.errors.empty? ? "This node cannot be deleted." : @node.errors.full_messages.join(" ")
      redirect_to node_path(@parent_id)
    end
  end

  private

  def set_child
    @child = Node.new(parent: @node)
  end

  def current_node
    @node = (params[:id] && Node.find_by_id(params[:id])) || Node.root
  end

  def parent_node
    Node.find_by_id(node_params[:parent_id])
  end

  def node_params
    params.require(:node).permit(:name, :parent_id, :description, :cost_code)
  end

end
