class NodesController < ApplicationController

  def show
    if params[:id]
      @node = Node.find(params[:id])
    else
      @node = Node.root
    end

    @child = Node.new(parent: @node)
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
    @node = Node.find(params[:id])

    respond_to do |format|
      format.html
      format.js { render template: 'nodes/modal' }
    end
  end

  def update
    @node = Node.find(params[:id])

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
    @node = Node.find(params[:id])

    if @node.destroy
      flash[:success] = "Node deleted"
      redirect_to node_path(@node.parent_id)
    else
      flash[:danger] = "A node with children cannot be deleted"
      redirect_to node_path(@node.parent_id)
    end
  end

  private

  def node_params
    params.require(:node).permit(:name, :parent_id, :description, :cost_code)
  end

end
