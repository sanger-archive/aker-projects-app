# Create Root Node
root = Node.new(name: "Institute Research QQ 2017-2021", owner_email: 'aker')
root.save(validate: false)

# Create programme nodes
cancer = Node.new(name: "Cancer, Aging & Somatic Mutations", parent: root, owner_email: 'aker')
cancer.save(validate: false)
cellular_genetics = Node.new(name: "Cellular Genetics", parent: root, owner_email: 'aker')
cellular_genetics.save(validate: false)
human_genetics = Node.new(name: "Human Genetics", parent: root, owner_email: 'aker')
human_genetics.save(validate: false)
infection_genomics = Node.new(name: "Infection Genomics", parent: root, owner_email: 'aker')
infection_genomics.save(validate: false)
malaria = Node.new(name: "Malaria", parent: root, owner_email: 'aker')
malaria.save(validate: false)
pathogens = Node.new(name: "Pathogens", parent: root, owner_email: 'aker')
pathogens.save(validate: false)

# Assign permissions to each node
malaria.permissions.create([{permitted: 'sg19@sanger.ac.uk', permission_type: :write}])
malaria.permissions.create([{permitted: 'mjs@sanger.ac.uk', permission_type: :write}])
infection_genomics.permissions.create([{permitted: 'dw2@sanger.ac.uk', permission_type: :write}])
infection_genomics.permissions.create([{permitted: 'kaa@sanger.ac.uk', permission_type: :write}])

# Development only - let anyone edit any node
[cancer, cellular_genetics, human_genetics, infection_genomics, malaria, pathogens].each do |programme|
  programme.permissions.create([{permitted: 'world', permission_type: :write}])
end
