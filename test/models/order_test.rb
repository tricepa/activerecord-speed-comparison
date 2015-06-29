require 'test_helper'

# Reference: Michael Hartl's Rails Tutorial
class OrderTest < ActiveSupport::TestCase
  def setup
    @client = Client.new(id: 1, name: "Patrice Liang", email: "patriceliang@gmail.com", active: true)
    @vendor = Vendor.new(id: 1, name: "Some Thrift Shop in Brooklyn", promotion: true)
    @client.save
    @order = @client.orders.create!(summary: "$21.99 Some Thrift Shop in Williamsburg order by Patrice Liang", vendor: @vendor)
  end

  test "should be valid" do
    assert @order.valid?
  end

  test "client id should be present" do
    @order.client_id = nil
    assert_not @order.valid?
  end

  test "vendor id should be present" do
    @order.vendor_id = nil
    assert_not @order.valid?
  end

  test "summary should be present" do
    @order.summary = ""
    assert_not @order.valid?
  end

  test "summary should be at most 140 characters" do
    @order.summary = "a" * 141
    assert_not @order.valid?
  end
end
