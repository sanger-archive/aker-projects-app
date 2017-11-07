root = Node.new(name: "root", owner_email: 'aker')
root.save(validate: false)

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

[cancer, cellular_genetics, human_genetics, infection_genomics, malaria, pathogens].each do |program|
  program.permissions.create([{permitted: 'world', permission_type: :write}])
end
