require 'test_helper'

class HookTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:active)
  should validate_presence_of(:url)
  should validate_presence_of(:external_id)
  should validate_presence_of(:hook_type)
  should belong_to(:user)
end
