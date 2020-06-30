class Hook < ApplicationRecord
  belongs_to :user
  validates :name, :active, :url, :external_id, :hook_type, presence: true
end
