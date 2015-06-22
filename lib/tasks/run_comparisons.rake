require 'rake'
require 'benchmark'

task :run_comparisons => :environment do
  desc "Compare relative runtimes of record retrieval using includes, joins, and enumeration"

  seed_database

  # demonstrate comparison with retrieval of client and vendor names of orders whose vendors have ongoing promotions
  orders = Order.joins(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
  orders.each do |order|
    puts "Using joins"
    puts "Notify #{order.client.name} at #{order.client.email} that #{order.vendor.name} is having a promotion!"
  end

  orders = Order.includes(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
  orders.each do |order|
    puts "Using includes"
    puts "Notify #{order.client.name} at #{order.client.email} that #{order.vendor.name} is having a promotion!"
  end

  orders = Order.all
  orders.each do |order|
    if order.vendor.promotion==true &&  order.client.active==true
      puts "Using enumeration"
      puts "Notify #{order.client.name} at #{order.client.email} that #{order.vendor.name} is having a promotion!"
    end
  end

  # demonstrate comparison with retrieval of only order info. Should demonstrate less discrepancy

  # demonstrate comparisons with larger dataset
end

def seed_database
  # clear tables
  clear_tables([Order, Client, Vendor])

  # load data
  Client.create!([
    {id: 1, name: "Joe K", email: "joek@example.com", active: true},
    {id: 2, name: "Estevan B", email: "estevanb@example.com", active: true}

  ])

  Vendor.create!([
    {id: 1, name: "ABC Home", promotion: false},
    {id: 2, name: "Schoolhouse Electric", promotion: true}
  ])

  Client.find(1).orders.create!(id: 1, summary: "Schoolhouse Order by Joe K", vendor: Vendor.find(2))
  Client.find(2).orders.create!(id: 2, summary: "ABC Order by Estevan B", vendor: Vendor.find(1))
end

def clear_tables(tables)
  tables.each do |t|
    t.delete_all
    t.delete_all
    t.delete_all
  end
end
