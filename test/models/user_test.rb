require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'valid users' do
    user_1 = User.new
    user_2 = User.new(email: 'invalid_email')
    user_3 = User.new(email: 'teste@email.com', password: '12345678')

    assert_not user_1.valid?
    assert_not user_2.valid?, user_2.errors.messages
    assert     user_3.valid?, user_3.errors.messages
    assert     users(:one).valid?, users(:one).errors.messages
  end
end
