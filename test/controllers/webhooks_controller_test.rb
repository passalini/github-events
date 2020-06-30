require 'test_helper'

class WebhooksControllerTest < ActionController::TestCase
  class UserVisualizationTest < WebhooksControllerTest
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

      sign_in user, scope: :user
      get :index

      assert_response :success
      assert_select "#secret-token", count: 1, text: user.secret_token
      assert_select "#repository-#{repository_1.id}", count: 1
      assert_select "#repository-#{repository_2.id}", count: 1
    end
  end

  class ApiTest < WebhooksControllerTest
    setup do
      request.accept = Mime[:json]
    end

    test '#POST create with ping event without token' do
      assert_no_difference -> { Repository.count } do
        post :create, params: load_data('github_ping.json')
        assert_response :unauthorized
      end
    end

    test '#POST create with ping event with invalid token' do
      @request.headers['HTTP_X_HUB_SIGNATURE'] = 'INVALID'

      assert_no_difference -> { Repository.count } do
        post :create, params: load_data('github_ping.json')
        assert_response :unauthorized
      end
    end

    test '#POST create with ping event' do
      user    = users(:one)
      @request.headers['HTTP_X_GITHUB_EVENT'] = 'ping'
      @request.headers['HTTP_X_HUB_SIGNATURE'] = user.secret_token

      assert_difference 'Event.count', 2 do
        assert_difference 'Repository.count', 1 do
          post :create, params: load_data('github_ping.json')
          assert_response :success

          # The second request is made to make sure to not duplicate the repository
          post :create, params: load_data('github_ping.json')
          assert_response :success
        end
      end

      assert_equal 186853261, json_body['external_id']
      assert_equal 'Octocoders/Hello-World', json_body['full_name']
      assert_equal 'https://github.com/Octocoders/Hello-World', json_body['html_url']
    end
  end
end
