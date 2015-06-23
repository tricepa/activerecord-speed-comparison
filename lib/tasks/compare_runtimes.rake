require 'rake'
require 'benchmark'

# Compares relative runtimes of Active Record record retrieval using .includes, .joins, and enumeration with different dataset sizes.
# Before running task, initialize database with appropriate tables and Client and Vendor seed data.
task :compare_runtimes => [:environment, :"db:reset"] do
  desc "Compare relative runtimes of Ative Record record retrieval using .includes, .joins, and enumeration with different dataset sizes"

  create_orders(5)
  puts "Retrieving order summmary of orders whose vendor has an ongoing promotion..."
  run_comparisons(false, true) # retrieve order summary of orders whose vendor has an ongoing promotion
  puts "Retrieving client name of orders whose vendor has an ongoing promotion..."
  run_comparisons(true, false) # retrieve client name of orders whose vendor has an ongoing promotion

  # Running comparisons with a larger order dataset demonstrates a dramatic increase in the runtime of enumeration method
  create_orders(500)
  puts "Retrieving order summmary of orders whose vendor has an ongoing promotion..."
  run_comparisons(false, true) # retrieve order summary of orders whose vendor has an ongoing promotion
  puts "Retrieving client name of orders whose vendor has an ongoing promotion..."
  run_comparisons(true, false) # retrieve client name of orders whose vendor has an ongoing promotion
end

# Boolean parameters indicate the attributes to retrieve of orders whose vendor has an ongoing promotion.
# The parameters are chosen to demonstrate performance differences with .includes, .joins, and enumeration
# when retrieving different data.
# Since the initial query is performed on the Order table, client info retrieval requires accessing a different
# table, whereas order info retrieval does not. The former retrieval demonstrates where '.includes' provides
# an advantage over '.joins.'
def run_comparisons(get_client_info, get_order_info)
  # Use Benchmark to retrieve real time elapsed of record retrieval.
  # Benchmark module reference: http://ruby-doc.org/stdlib-2.0.0/libdoc/benchmark/rdoc/Benchmark.html
  joins_runtime = Benchmark.realtime do
    orders = Order.joins(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
    orders.each do |order|
      get_client_info && order.client.name # perform query to retrieve client name if get_client_info is true
      get_order_info && order.summary # perform query to retrieve order summary if get_order_info is true
    end
  end

  includes_runtime = Benchmark.realtime do
    orders = Order.includes(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
    orders.each do |order|
      get_client_info && order.client.name # perform query to retrieve client name if get_client_info is true
      get_order_info && order.summary # perform query to retrieve order summary if get_order_info is true
    end
  end

  enumeration_runtime = Benchmark.realtime do
    orders = Order.all
    orders.each do |order|
      if order.vendor.promotion==true &&  order.client.active==true
        get_client_info && order.client.name # perform query to retrieve client name if get_client_info is true
        get_order_info && order.summary # perform query to retrieve order summary if get_order_info is true
      end
    end
  end
  puts "That took #{joins_runtime} seconds with .joins, #{includes_runtime} seconds with .includes, and #{enumeration_runtime} seconds with enumeration.\n\n"
end

# parameter specifies number of orders to insert into database
def create_orders(order_count)
  Order.delete_all

  client_count = Client.count
  vendor_count = Vendor.count

  # Use Random module to randomly associate clients and vendors with new orders.
  # Random number generator reference: http://ruby-doc.org/core-2.1.3/Random.html
  prng = Random.new
  order_count.times do |n|
    client = Client.find(prng.rand(1..client_count))
    vendor = Vendor.find(prng.rand(1..vendor_count))
    client.orders.create!(id: "#{n+1}", summary: "#{vendor.name} order by #{client.name}", vendor: vendor)
  end

  puts "The database now has #{order_count} orders.\n\n"
end

