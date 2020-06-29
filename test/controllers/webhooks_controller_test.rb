require 'test_helper'

class WebhooksControllerTest < ActionController::TestCase
  test '#GET index for unlogged user' do
    get :index

    assert_response :redirect
    assert_redirected_to user_session_path
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
  end

  test '#GET index for signed user' do
    sign_in users(:one), scope: :user

    get :index

    assert_response :success
  end
end
