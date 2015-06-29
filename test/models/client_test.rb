require 'test_helper'

# Reference: Michael Hartl's Rails Tutorial
class ClientTest < ActiveSupport::TestCase

  def setup
    @client = Client.new(id: 1, name: "Patrice Liang", email: "patriceliang@gmail.com", active: true)
    @vendor = Vendor.new(id: 1, name: "Some Thrift Shop in Brooklyn", promotion: true)
  end

  test "should be valid" do
    assert @client.valid?
  end

  test "name should be present" do
    @client.name = ""
    assert_not @client.valid?
  end

  test "email should be present" do
    @client.email = " "
    assert_not @client.valid?
  end

  test "name should not be too long" do
    @client.name = "a" * 51
    assert_not @client.valid?
  end

  test "email should not be too long" do
    @client.email = "a" * 244 + "@example.com"
    assert_not @client.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @client.email = valid_address
      assert @client.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @client.email = invalid_address
      assert_not @client.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_client = @client.dup
    duplicate_client.email = @client.email.upcase
    @client.save
    assert_not duplicate_client.valid?
  end

  test "associated orders should be destroyed" do
    @client.save
    @client.orders.create!(summary: "$21.99 Some Thrift Shop in Williamsburg order by Patrice Liang", vendor: @vendor)
    assert_difference 'Order.count', -1 do
      @client.destroy
    end
  end

end
