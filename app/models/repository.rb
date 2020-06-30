class Repository < ApplicationRecord
  has_many :events
  validates :external_id, :full_name, :html_url, presence: true
end
