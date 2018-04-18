class MoveDrsToSubprojects < ActiveRecord::Migration[5.0]
  def change
    Node.is_project.each do |project_node|
      # Add Data Release Strategy to sub-projects
      if project_node.data_release_strategy_id
        project_node.nodes.each do |child|
          child.update(data_release_strategy_id: project_node.data_release_strategy_id)
        end
      end

      # Remove DRS from project
      project_node.update(data_release_strategy_id: nil)
    end
  end
end
