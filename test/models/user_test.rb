require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of(:email)
  should validate_presence_of(:password)

  test '#secret_token' do
    user = users(:one)
    assert_equal Base64.urlsafe_encode64(user.email), user.secret_token
  end
end
