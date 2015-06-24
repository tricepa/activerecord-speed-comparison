require 'rake'
require 'benchmark'

# Compares relative runtimes of Active Record record retrieval using .includes, .joins, and enumeration with different dataset sizes.
# Before running task, initialize database with appropriate tables and Client and Vendor seed data.
task :compare_runtimes => [:environment, :"db:reset"] do
  desc "Compare relative runtimes of Ative Record record retrieval using .includes, .joins, and enumeration with different dataset sizes"

  create_orders(5)
  puts "Retrieving orders whose vendor has an ongoing promotion..."
  run_comparisons("order")
  puts "Retrieving clients of orders whose vendor has an ongoing promotion..."
  run_comparisons("client")

  # Running comparisons with a larger order dataset demonstrates a dramatic increase in the runtime of enumeration method
  create_orders(500)
  puts "Retrieving orders whose vendor has an ongoing promotion..."
  run_comparisons("order")
  puts "Retrieving clients of orders whose vendor has an ongoing promotion..."
  run_comparisons("client")
end

# "Request" parameter specifies which table to retrieve records from of orders whose vendor has an ongoing promotion.
# Currently, the parameter can have value 'order,' 'client,' or 'vendor.' Having this parameter allows demonstration
# of how '.includes,' '.joins, and enumeration perform under different retrieval scenarios.
# For example, since the initial query is performed on the Order table, client info retrieval requires accessing a different
# table, whereas order info retrieval does not. The former retrieval demonstrates where '.includes' provides an
# advantage over '.joins.'
def run_comparisons(request)
  joins_results = Set.new # Unique records from using the .joins method
  includes_results = Set.new # Unique records from using the .includes method
  enumeration_results = Set.new # Unique records from using the enumeration method

  # Use Benchmark to retrieve real time elapsed of record retrieval.
  # Benchmark module reference: http://ruby-doc.org/stdlib-2.0.0/libdoc/benchmark/rdoc/Benchmark.html
  joins_runtime = Benchmark.realtime do
    joins_results = retrieve_with_joins(request, joins_results)
  end

  includes_runtime = Benchmark.realtime do
    includes_results = retrieve_with_includes(request, includes_results)
  end

  enumeration_runtime = Benchmark.realtime do
    enumeration_results = retrieve_with_enumeration(request, enumeration_results)
  end

  joins_results_count = joins_results.count
  includes_results_count = includes_results.count
  enumeration_results_count = enumeration_results.count

  # Print the number of records retrieved and the time elapsed using all three methods.
  # Confirm that all three methods performed the same record retrievals.
  puts "#{joins_results_count} unique #{request}(s) were retrieved using .joins, #{includes_results_count} unique #{request} were retrieved using .includes, and #{enumeration_results_count} unique #{request} were retrieved using enumeration."
  puts "That took #{joins_runtime} seconds with .joins, #{includes_runtime} seconds with .includes, and #{enumeration_runtime} seconds with enumeration.\n\n"
end

# Use ".joins" to find all orders whose vendor has an ongoing promotion
# Return an array of unique records associated to the orders, specified by the "request" parameter
def retrieve_with_joins(request, results)
  orders = Order.joins(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
  orders.each do |order|
    results.add(get_record(order, request)) # Store unique records in Set
  end
  return results
end

# Use ".includes" to find all orders whose vendor has an ongoing promotion
# Return an array of unique records associated to the orders, specified by the "request" parameter
def retrieve_with_includes(request, results)
  orders = Order.includes(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
  orders.each do |order|
    # Although the records in includes_results will match the ones in joins_results, this ensures consistency in order to compare relative runtimes
    results.add(get_record(order, request))
  end
  return results
end

# Use the enumeration method to find all orders whose vendor has an ongoing promotion
# Return an array of unique records associated to the orders, specified by the "request" parameter
def retrieve_with_enumeration(request, results)
  orders = Order.all
  orders.each do |order|
    if order.vendor.promotion==true &&  order.client.active==true
      # Although the records in enumeration_results will match the ones in joins_results and includes_results, this ensures consistency in order to compare relative runtimes
      results.add(get_record(order, request))
    end
  end
  return results
end

# Retrieve and return ID of requested table associated with the given order parameter
# Acceptable inputs can easily be added in the future
def get_record(order, request)
  case request
  when "order"
    return order.id
  when "client"
    return order.client.id
  when "vendor"
    return order.vendor.id
  else
    raise ArgumentError, "'request' parameter must be 'order,' 'client,' or 'vendor'"
  end
end

# Insert into the database number of orders specified by the "order_count" parameter
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

