require 'test_helper'

class WebhooksControllerTest < ActionController::TestCase
  test '#GET index for unlogged user' do
    get :index

    assert_response :redirect
    assert_redirected_to user_session_path
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
  end

  test '#GET index for signed user' do
    user   = users(:one)
    repository_1 = repositories(:one)
    repository_2 = repositories(:two)
    ENV['SECRET_TOKEN'] = 'TEST'

    sign_in user, scope: :user
    get :index

    assert_response :success
    assert_select "#hook-url", count: 1, text: events_url
    assert_select "#secret-token", count: 1, text: 'TEST'
    assert_select "#repository-#{repository_1.id}", count: 1
    assert_select "#repository-#{repository_2.id}", count: 1
  end
end
