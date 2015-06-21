class Vendor < ActiveRecord::Base
  has_many :promotions, dependent: :destroy
end
