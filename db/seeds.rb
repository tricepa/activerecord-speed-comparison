Order.delete_all
Client.delete_all
Vendor.delete_all

Client.create!([
  {id: 1, name: "Joe K", email: "joek@example.com", active: true},
  {id: 2, name: "Estevan B", email: "estevanb@example.com", active: true}

])

Vendor.create!([
  {id: 1, name: "ABC Home", promotion: false},
  {id: 2, name: "Schoolhouse Electric", promotion: true}
])

# create orders
Client.find(1).orders.create!(id: 1, summary: "Schoolhouse Order by Joe K", vendor: Vendor.find(2))
Client.find(2).orders.create!(id: 2, summary: "ABC Order by Estevan B", vendor: Vendor.find(1))

