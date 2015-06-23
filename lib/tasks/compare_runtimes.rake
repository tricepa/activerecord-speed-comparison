require 'rake'
require 'benchmark'

# Compares relative runtimes of Active Record record retrieval using .includes, .joins, and enumeration with different dataset sizes.
# Before running task, initialize database with appropriate tables and Client and Vendor seed data.
task :compare_runtimes => [:environment, :"db:reset"] do
  desc "Compare relative runtimes of Ative Record record retrieval using .includes, .joins, and enumeration with different dataset sizes"

  create_orders(5)
  puts "Retrieving orders whose vendor has an ongoing promotion..."
  run_comparisons(["order"])
  puts "Retrieving clients of orders whose vendor has an ongoing promotion..."
  run_comparisons(["client"])

  # Running comparisons with a larger order dataset demonstrates a dramatic increase in the runtime of enumeration method
  create_orders(500)
  puts "Retrieving orders whose vendor has an ongoing promotion..."
  run_comparisons(["order"])
  puts "Retrieving clients of orders whose vendor has an ongoing promotion..."
  run_comparisons(["client"])
end

# "Request" parameter is an array that specifies which tables to retrieve of orders whose vendor has an ongoing promotion.
# Currently, the parameter can have value 'order,' 'client,' or 'vendor.' Having this parameter allows demonstration
# of how '.includes,' '.joins, and enumeration perform under different retrieval scenarios.
# For example, since the initial query is performed on the Order table, client info retrieval requires accessing a different
# table, whereas order info retrieval does not. The former retrieval demonstrates where '.includes' provides an
# advantage over '.joins.'
def run_comparisons(request)
  # Use Benchmark to retrieve real time elapsed of record retrieval.
  # Benchmark module reference: http://ruby-doc.org/stdlib-2.0.0/libdoc/benchmark/rdoc/Benchmark.html
  joins_results = Set.new
  includes_results = Set.new
  enumeration_results = Set.new

  joins_runtime = Benchmark.realtime do
    orders = Order.joins(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
    orders.each do |order|
      joins_results.add(get_info(order, request))
    end
  end

  includes_runtime = Benchmark.realtime do
    orders = Order.includes(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
    orders.each do |order|
      includes_results.add(get_info(order, request))
    end
  end

  enumeration_runtime = Benchmark.realtime do
    orders = Order.all
    orders.each do |order|
      if order.vendor.promotion==true &&  order.client.active==true
        enumeration_results.add(get_info(order, request))
      end
    end
  end

  joins_results_count = joins_results.count
  includes_results_count = includes_results.count
  enumeration_results_count = enumeration_results.count

  if joins_results_count == includes_results_count && includes_results_count == enumeration_results_count
    puts "#{joins_results_count} unique #{request}(s) retrieved."
  else
    puts "#{joins_results_count} unique #{request} were retrieved from using .joins, #{includes_results_count} unique #{request} were retrieved from using .includes, and #{enumeration_results_count} unique #{request} were retrieved from using enumeration."
  end
  puts "That took #{joins_runtime} seconds with .joins, #{includes_runtime} seconds with .includes, and #{enumeration_runtime} seconds with enumeration.\n\n"
end

# Retrieve and output information on requested tables
def get_info(order, request)
  request.each do |table|
    case table
    when "order"
      return order.id
    when "client"
      return order.client.id
    when "vendor"
      return order.vendor.id
    else
      puts "error"# raise error
    end
  end
end

# Parameter specifies number of orders to insert into database
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

