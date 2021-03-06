class Client < ActiveRecord::Base
  has_many :orders, dependent: :destroy
  validates :active, inclusion: { in: [true, false] }
  # Reference: Michael Hartl's Rails Tutorial book
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255}, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}
end
