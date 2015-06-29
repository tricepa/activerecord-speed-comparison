require 'rake'
require 'benchmark'

# Compares relative runtimes of Active Record record retrieval using .includes, .joins, and enumeration with different dataset sizes.
# Before running task, initialize database with appropriate tables and Client and Vendor seed data.
task :compare_runtimes => [:environment, :"db:reset"] do
  desc "Compare relative runtimes of Active Record record retrieval using .includes, .joins, and enumeration with different dataset sizes"
  # Demonstrate the negligible runtime differences of the three methods with a small dataset of orders
  create_orders(5)
  run_comparisons("order")
  run_comparisons("client")
  # Run comparisons with a larger dataset of orders to demonstrate runtime differences
  create_orders(500)
  run_comparisons("order")
  run_comparisons("client")
end

# "Request" parameter specifies which table to retrieve records from of orders whose vendor has an ongoing promotion.
# Currently, the parameter can have value 'order,' 'client,' or 'vendor.' Having this parameter allows demonstration
# of how '.includes,' '.joins, and enumeration perform under different retrieval scenarios.
# For example, since the initial query is performed on the Order table, client info retrieval requires accessing a different
# table, whereas order info retrieval does not. The former retrieval demonstrates where '.includes' provides an
# advantage over '.joins.'
def run_comparisons(request)
  puts "Retrieving #{request=="order" ? "orders" : request + "s of orders"} whose vendor has an ongoing promotion..."
  joins_results = Set.new # Unique records from using the .joins method
  includes_results = Set.new # Unique records from using the .includes method
  enumeration_results = Set.new # Unique records from using the enumeration method
  # Use Benchmark to print a comparison table of record retrieval runtimes using the three methods
  # Benchmark module reference: http://ruby-doc.org/stdlib-2.0.0/libdoc/benchmark/rdoc/Benchmark.html
  Benchmark.bm(13) do |bm|
    bm.report(".joins:") do
      joins_results = retrieve_with_joins(request, joins_results)
    end
    bm.report(".includes:") do
      includes_results = retrieve_with_includes(request, includes_results)
    end
    bm.report("enumeration:") do
      enumeration_results = retrieve_with_enumeration(request, enumeration_results)
    end
  end
  joins_results_count = joins_results.count
  includes_results_count = includes_results.count
  enumeration_results_count = enumeration_results.count
  # Print the number of records retrieved; confirm that all three methods performed the same record retrievals
  puts "#{joins_results_count} unique #{request}s were retrieved using .joins, #{includes_results_count} unique #{request}s were retrieved using .includes, and #{enumeration_results_count} unique #{request}s were retrieved using enumeration.\n\n"
end

# Use ".joins" to find all orders whose vendor has an ongoing promotion
# Return an array of unique record ID's (the record source is specified by the "request" parameter) associated to the orders
def retrieve_with_joins(request, results)
  orders = Order.joins(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
  orders.each do |order|
    results.add(get_record_id(order, request)) # Store unique records in Set
  end
  return results
end

# Use ".includes" to find all orders whose vendor has an ongoing promotion
# Return an array of unique record ID's (the record source is specified by the "request" parameter) associated to the orders
def retrieve_with_includes(request, results)
  orders = Order.includes(:client, :vendor).where(vendors: {promotion: true}, clients: {active: true})
  orders.each do |order|
    # Although the records in includes_results will match the ones in joins_results, this ensures consistency in order to compare relative runtimes
    results.add(get_record_id(order, request))
  end
  return results
end

# Use the enumeration method to find all orders whose vendor has an ongoing promotion
# Return an array of unique record ID's (the record source is specified by the "request" parameter) associated to the orders
def retrieve_with_enumeration(request, results)
  orders = Order.all
  orders.each do |order|
    if order.vendor.promotion==true &&  order.client.active==true
      # Although the records in enumeration_results will match the ones in joins_results and includes_results, this ensures consistency in order to compare relative runtimes
      results.add(get_record_id(order, request))
    end
  end
  return results
end

# Retrieve and return ID of requested table associated with the given order parameter
# Acceptable inputs can easily be added in the future
def get_record_id(order, request)
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
    client.orders.create!(id: "#{n+1}", summary: "$#{prng.rand(0.01..3000.00).round(2)} order by #{client.name} from #{vendor.name}", vendor: vendor)
  end
  puts "There are now #{order_count} orders in the database.\n\n"
end

