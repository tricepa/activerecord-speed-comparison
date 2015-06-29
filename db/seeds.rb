# Seed database with Client and Vendor entries
# Create clients with random names and state (active or inactive)
CLIENT_COUNT = 100
CLIENT_COUNT.times do |n|
  Client.create!([
    {id: "#{n+1}", name: Faker::Name.name, email: "aspiring_home-lover#{n+1}@example.com", active: [true, false].sample}
  ])
end
active_client_count = Client.where(active: true).count
puts "There are now #{CLIENT_COUNT} clients in the database, #{active_client_count} of which are active."

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
  {id: 10, name: "Some Thrift Shop in Williamsburg", promotion: [true, false].sample}
])
vendors_with_promo_count = Vendor.where(promotion: true).count
puts "There are now 10 vendors in the database, #{vendors_with_promo_count} of which have an ongoing promotion.\n\n"

