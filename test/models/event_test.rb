require 'test_helper'

class EventTest < ActiveSupport::TestCase
  should validate_presence_of(:repository)
  should validate_presence_of(:payload)
  should validate_presence_of(:kind)
  should belong_to(:repository)
end
