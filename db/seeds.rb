root = Node.create(name: "root")

cancer = Node.create(name: "Cancer, Aging & Somatic Mutations", parent: root, no_collection: true)
cellular_genetics = Node.create(name: "Cellular Genetics", parent: root, no_collection: true)
human_genetics = Node.create(name: "Human Genetics", parent: root, no_collection: true)
infection_genomics = Node.create(name: "Infection Genomics", parent: root, no_collection: true)
malaria = Node.create(name: "Malaria", parent: root, no_collection: true)
pathogens = Node.create(name: "Pathogens", parent: root, no_collection: true)

Collection.create([
  { set_id: "f6017957-9c62-48b8-b3d6-794986e95ee6", collector_type: "Node", collector_id: cancer.id },
  { set_id: "3e978e6f-bbef-4946-bd68-6a4324e5cb4d", collector_type: "Node", collector_id: cellular_genetics.id },
  { set_id: "5ef4fdd2-1abf-495c-aec2-d8a9af5e5ca6", collector_type: "Node", collector_id: human_genetics.id },
  { set_id: "1b082a95-f867-42d5-9f3d-95e28ab2125b", collector_type: "Node", collector_id: infection_genomics.id },
  { set_id: "e7a5fd55-f501-4b49-8cd4-e490b9693f4a", collector_type: "Node", collector_id: malaria.id },
  { set_id: "9fc2c0d3-51b2-44c4-88a6-64ac02e7a80d", collector_type: "Node", collector_id: pathogens.id },
])