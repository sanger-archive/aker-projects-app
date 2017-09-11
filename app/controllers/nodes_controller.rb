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

    @node_form = NodeForm.new(node_form_params.merge(owner: current_user))

    if @node_form.save
      flash[:success] = "Node created"
    else
      flash[:danger] = "Failed to create node"
    end
    redirect_to node_path(@node_form.parent_id)
  end

  def edit
    authorize! :read, current_node

    set_form

    respond_to do |format|
      format.html
      format.js { render template: 'nodes/modal' }
    end
  end

  def update
    authorize! :write, current_node

    respond_to do |format|
      @node_form = NodeForm.new(node_form_params)

      if @node_form.save
        format.html { redirect_to node_path(@node.parent_id), flash: { success: "Node updated" }}
        format.json { render json: @node, status: :ok }
      else
        format.html {
          flash[:error] = @node_form.error_messages.full_messages
          redirect_to edit_node_path(@node.id)
        }
        format.json { render json: @node_form.error_messages, status: :unprocessable_entity }
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

  helper_method :check_write_permission_for_node

  private

  def set_form
    @nodeform = NodeForm.from_node(@node)
  end

  def set_child
    @child = NodeForm.new(parent_id: @node.id)
  end

  def current_node
    @node = (params[:id] && Node.find_by_id(params[:id])) || Node.root
  end

  def parent_node
    Node.find_by_id(node_form_params[:parent_id])
  end

  def node_form_params
    params.require(:node_form).permit(NodeForm::ATTRIBUTES)
  end

  def check_write_permission_for_node(node)
    Ability.new(current_user).can?(:write, node)
  end

end
