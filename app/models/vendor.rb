class Vendor < ActiveRecord::Base
  has_many :orders
end
