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

  test '#POST create with ping event' do
    request.accept = Mime[:json]

    assert_changes('Hook.count', 1) do
      post :create, params: load_data('github_ping.json')
      assert_response :success
    end

    assert json_body['active']
    assert_equal 'web', json_body['name']
    assert_equal 109948940, json_body['external_id']
  end
end
