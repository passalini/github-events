require 'test_helper'

class IssueEventTest < ActiveSupport::TestCase
  should validate_presence_of(:repository)
  should validate_presence_of(:payload)
  should validate_presence_of(:kind)
  should validate_presence_of(:external_id)
  should belong_to(:repository)
end
