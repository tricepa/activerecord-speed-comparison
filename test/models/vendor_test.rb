require 'test_helper'

# Reference: Michael Hartl's Rails Tutorial
class VendorTest < ActiveSupport::TestCase
  def setup
    @vendor = Vendor.new(id: 1, name: "Some Thrift Shop in Brooklyn", promotion: true)
  end

  test "should be valid" do
    assert @vendor.valid?
  end

  test "name should be present" do
    @vendor.name = ""
    assert_not @vendor.valid?
  end

  test "promotion should be present" do
    @vendor.promotion = ""
    assert_not @vendor.valid?
  end

  test "name should not be too long" do
    @vendor.name = "a" * 51
    assert_not @vendor.valid?
  end
end
