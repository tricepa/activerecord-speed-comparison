class Order < ActiveRecord::Base
  # Since an Order is the link between a Client and a Vendor, it belongs to both models
  belongs_to :client
  belongs_to :vendor
  validates :client_id, presence: true
  validates :vendor_id, presence: true
  validates :summary, presence: true, length: {maximum: 140}
end
