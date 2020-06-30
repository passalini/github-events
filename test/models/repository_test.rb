require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  should validate_presence_of(:external_id)
  should validate_presence_of(:full_name)
  should validate_presence_of(:html_url)
  should have_many(:events)
end
