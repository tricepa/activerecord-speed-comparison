class Client < ActiveRecord::Base
  belongs_to :designer
  has_many :orders, dependent: :destroy
end
