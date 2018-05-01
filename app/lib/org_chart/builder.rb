module OrgChart
  class Builder

    def self.build
      OrgChart::Tree.new(node: Node.root)
    end

  end
end