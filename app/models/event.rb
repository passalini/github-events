class Event < ApplicationRecord
  belongs_to :repository
  validates :repository, :kind, :payload, presence: true
end
