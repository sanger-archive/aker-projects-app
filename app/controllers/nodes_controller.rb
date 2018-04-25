  class NodesController < ApplicationController
  include AkerPermissionControllerConfig
  include WebSocketsNotification

  before_action :current_node, except: :create
  before_action :build_org_chart, except: :create
  before_action :set_child, only: [:show, :tree]

  def show
    authorize! :read, Node
    render :tree
  end

  def index
    authorize! :read, Node
    respond_to do |format|
      format.json { render json: @tree }
    end
  end

  def tree
    authorize! :read, Node
  end

  def create
    authorize! :create, Node, message: 'You are not authorized to create this node.'
    # You must have write permission on the parent node to create
    # Everyone is allowed to create a node under root
    authorize! :write, parent_node

    @node_form = NodeForm.new(node_form_params.merge(owner_email: current_user.email, user_email: current_user.email))

    if @node_form.save
      flash[:success] = 'Node created'
    else
      flash[:danger] = 'Failed to create node'
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
      @node_form = NodeForm.new(node_form_params.merge(user_email: current_user.email))
      if @node_form.save
        notify_changes_with_websockets

        format.html { redirect_to node_path(@node.parent_id), flash: { success: 'Node updated' } }
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

    if @node.deactivate(current_user.email)
      flash[:success] = 'Node deleted'
    else
      flash[:danger] = @node.errors.empty? ? 'This node cannot be deleted.' : @node.errors.full_messages.join(' ')
    end
    redirect_to node_path(@parent_id)
  end

  helper_method :check_write_permission_for_node, :jwt_provided?, :can_edit_permission_for, :current_user

  private

  def build_org_chart
    @tree = Rails.cache.fetch("org_chart", expires_in: 7.days) do
      OrgChart::Builder.build.to_json
    end
  end

  def set_form
    @nodeform = NodeForm.from_node(@node, current_user.email)
  end

  def set_child
    @child = NodeForm.new(parent_id: @node.id, user_email: current_user.email)
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
    current_user && Ability.new(current_user).can?(:write, node)
  end

  def can_edit_permission_for(node)
    check_write_permission_for_node(node) && !node.is_subproject?
  end

end
