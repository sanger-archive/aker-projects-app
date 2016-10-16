### Human Genetics and family...
human_genetics = Program.create!(name: 'Human Genetics')

project = human_genetics.projects.create!(name: 'Causes, mechanisms & reversability')

project.aims.create!([
  { name: 'Aim 1: Causes & mechanism of rare' },
  { name: 'Aim 2: Causes & mechanisms of rare metabolic...' },
  { name: 'Aim 3: Assessing reversability' }
])

aim = project.aims.create!( name: 'Phentypic variability in rare disorders' )

proposal = aim.proposals.create!( name: 'Somatic variation proposal' )

### Cancer, Aging & Somatic Mutations and family...
cancer = Program.create!(name: 'Cancer, Aging & Somatic Mutations')

project = cancer.projects.create!( name: 'The Cancer Genome Project' )

project.aims.create!([
  { name: 'Pan-Cancer QPQ' },
  { name: 'COSMIC' }
])

aim = project.aims.create!( name: 'Systemic derevation' )

proposal = aim.proposals.create!( name: 'Organoids proposal' )

### The rest of the programs
Program.create([
  { name: "Pathogens" },
  { name: "Malaria" },
  { name: "Cellular Genetics" },
  { name: "Computational Genomics" }
])