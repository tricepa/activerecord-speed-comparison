class Vendor < ActiveRecord::Base
  has_many :orders
  validates :name, presence: true, length: {maximum: 50}
  validates :promotion, inclusion: { in: [true, false] }
end
