root = Node.new(name: "root")
root.save(validate: false)

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

cancer.permissions.create([{permitted: 'world', r: true, w: true}])
cellular_genetics.permissions.create([{permitted: 'world', r: true, w: true}])
human_genetics.permissions.create([{permitted: 'world', r: true, w: true}])
infection_genomics.permissions.create([{permitted: 'world', r: true, w: true}])
malaria.permissions.create([{permitted: 'world', r: true, w: true}])
pathogens.permissions.create([{permitted: 'world', r: true, w: true}])

Collection.create([
  { set_id: "f6017957-9c62-48b8-b3d6-794986e95ee6", collector_type: "Node", collector_id: cancer.id },
  { set_id: "3e978e6f-bbef-4946-bd68-6a4324e5cb4d", collector_type: "Node", collector_id: cellular_genetics.id },
  { set_id: "5ef4fdd2-1abf-495c-aec2-d8a9af5e5ca6", collector_type: "Node", collector_id: human_genetics.id },
  { set_id: "1b082a95-f867-42d5-9f3d-95e28ab2125b", collector_type: "Node", collector_id: infection_genomics.id },
  { set_id: "e7a5fd55-f501-4b49-8cd4-e490b9693f4a", collector_type: "Node", collector_id: malaria.id },
  { set_id: "9fc2c0d3-51b2-44c4-88a6-64ac02e7a80d", collector_type: "Node", collector_id: pathogens.id },
])