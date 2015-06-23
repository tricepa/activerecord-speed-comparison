class Order < ActiveRecord::Base
  belongs_to :client
  belongs_to :vendor
  validates :client_id, presence: true
  validates :vendor_id, presence: true
end
