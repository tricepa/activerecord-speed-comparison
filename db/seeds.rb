# Seed database with Client and Vendor entries

# Create 100 clients with random names and active state
100.times do |n|
  Client.create!([
    {id: "#{n+1}", name: Faker::Name.name, email: "aspiring_home-lover#{n+1}@example.com", active: [true, false].sample}
  ])
end

# Create ten vendors with random promotion state
Vendor.create!([
  {id: 1, name: "ABC Home", promotion: [true, false].sample},
  {id: 2, name: "Schoolhouse Electric", promotion: [true, false].sample},
  {id: 3, name: "Serena & Lily", promotion: [true, false].sample},
  {id: 4, name: "Crate & Barrel", promotion: [true, false].sample},
  {id: 5, name: "Room & Board", promotion: [true, false].sample},
  {id: 6, name: "DWR", promotion: [true, false].sample},
  {id: 7, name: "CB2", promotion: [true, false].sample},
  {id: 8, name: "Restoration Hardware", promotion: [true, false].sample},
  {id: 9, name: "Dwell Studio", promotion: [true, false].sample},
  {id: 10, name: "Some thrift shop in Williamsburg", promotion: [true, false].sample}
])

