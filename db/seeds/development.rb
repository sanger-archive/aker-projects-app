root = Node.new(name: "root")
root.save(validate: false)
root.permissions.create([{permitted: 'world', permission_type: :read}])

cancer = Node.new(name: "Cancer, Aging & Somatic Mutations", parent: root)
cancer.save(validate: false)
cellular_genetics = Node.new(name: "Cellular Genetics", parent: root)
cellular_genetics.save(validate: false)
human_genetics = Node.new(name: "Human Genetics", parent: root)
human_genetics.save(validate: false)
infection_genomics = Node.new(name: "Infection Genomics", parent: root)
infection_genomics.save(validate: false)
malaria = Node.new(name: "Malaria", parent: root)
malaria.save(validate: false)
pathogens = Node.new(name: "Pathogens", parent: root)
pathogens.save(validate: false)

[cancer, cellular_genetics, human_genetics, infection_genomics, malaria, pathogens].each do |program|
  program.permissions.create([{permitted: 'world', permission_type: :read}, {permitted: 'world', permission_type: :write}])
end