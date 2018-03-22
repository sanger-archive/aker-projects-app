# Find the root node
root = Node.find_by(id: 1)

# Create the root node if it doesn't exist
unless root
  root = Node.new(name: "Institute Research QQ 2017-2021", owner_email: 'aker')
  root.save(validate: false)
end

# Update the root name if it's incorrect
if root.name != "Institute Research QQ 2017-2021"
  # Using update_attribute to skip validations, as the root node is invalid
  root.name = "Institute Research QQ 2017-2021"
  root.save(validate: false)
end

# Define programmes and their owners
programmes = { "Cancer, Aging & Somatic Mutations": ['som', 'cs4', 'im4', 'cdt'],
              "Cellular Genetics": ['js43', 'el4', 'bh11', 'gc10'],
              "Human Genetics": ['njl', 'sarah', 'sb49', 'kd9'],
              "Infection Genomics": ['dw2', 'kaa'],
              "Malaria": ['sg19', 'mjs', 'aa15']
            }

# Use the above definitions to create programme nodes and assign permissions
programmes.each do |prog, owners|
  # Create the node if it doesn't exist
  node = Node.where(name: prog).first_or_create(parent: root, owner_email: 'aker')
  node.save(validate: false)

  # Assign permissions for each owner, if they don't already exist
  owners.each do |owner|
    node.permissions.where(permitted: "#{owner}@sanger.ac.uk", permission_type: :write).first_or_create
  end

  # Remove permissions for the 'aker' user
  node.permissions.where(permitted: "aker").destroy_all
end
