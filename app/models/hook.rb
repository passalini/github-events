class Hook < ApplicationRecord
  validates :name, :active, :url, :external_id, :hook_type, presence: true
end
