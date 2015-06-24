# Active Record Speed Comparison

This application compares the relative runtime speeds of using ".includes," ".joins," and simple enumeration to retrieve Active Record records through a single rake task "compare_runtimes.rake."

## Development Environment
This application requires Ruby, Rails, and PostgreSQL installations. 

Ruby version used for development: 2.1.1

Rails version used for development: 4.2.2

## Design and Implementation Process
Given the prompt, I learned about the differences among the three methods of querying using the RoR guide as a resource: http://guides.rubyonrails.org/active_record_querying.html. I identified two main factors that would demonstrate performance differences among the three methods - size of dataset and whether the record to retrieve is in the table that the .joins/.includes/enumeration operation was performed on.

In an attempt to demonstrate the comparison in a fun and relevant way, I imagined a scenario in which Homepolish Swatch vendors are able to push promotions through Homepolish. The Client, Vendor, and Order models enable a designer/Queen Bee to identify clients that have previously ordered from a vendor with an ongoing promotion. This benefits the vendor as well as clients who have demonstrated interest in the vendor based on order history.

In designing the models, I used the RoR guide for associations as a resource: http://guides.rubyonrails.org/association_basics.html.

I compare the relative runtimes of ".includes," ".joins," and simple enumeration by using the three methods on the Order table to separately retrieve all the orders that are from a vendor with an ongoing promotion. 

I used the Benchmark module (http://ruby-doc.org/stdlib-2.1.1/libdoc/benchmark/rdoc/Benchmark.html) to measure the runtimes of the record retrieval code blocks. Although the module has functionality to output the user, system, total, and real times of operation, since we are concerned with relative runtimes I limited the output to the real time elapsed.

To satisfy the requirement of having the entire application executable from a single rake task, I found the following article to be a helpful starting point: https://richonrails.com/articles/building-a-simple-rake-task. As I implemented and tested my application, I built on and veered from that simple model. For example, I decided to seed the database with Client and Vendor data from "seeds.rb" because the data is pretty static and this allows the seeding to be done independently of the rake task. I chose to seed the Order records in the rake task to allow for more dynamic seeding.

## Results

With a small dataset (5 orders), the results vary and there are instances where enumeration actually performs the fastest.

With a larger dataset (500 orders), however, there are more consistent results. When retrieving just the orders whose vendor has an ongoing promotion, ".joins" was relatively faster than ".includes." This makes sense because ".joins" is preferable when used for filtering, whereas ".includes" expends additional time to eager-load associations.

When retrieving the clients of those orders, however, ".includes" wins out by far. This makes sense, as ".includes" uses eager-loading and does not require separate SQL queries to retrieve the client association of the orders. In both cases, it is clear that enumeration consistently takes the longest to run. 

## Usage & Data

Clone repo:

git clone https://github.com/tricepa/activerecord-speed-comparison.git

cd activerecord-speed-comparison

Install gem dependencies:

bundle install

Run rake task:

rake compare_runtimes

The rake task "compare_runtimes.rake" takes care of creating the database, loading the appropriate tables from "schema.rb," and seeding the database with the Client and Vendor data in "seeds.rb." Orders are inserted dynamically in the rake task itself to demonstrate comparisons with differently sized datasets.

## TODO
Given the time constraint, I did not include a test suite for this application. 

Thanks for reading!