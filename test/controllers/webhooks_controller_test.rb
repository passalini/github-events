require 'test_helper'

class WebhooksControllerTest < ActionController::TestCase
  setup { ENV['SECRET_TOKEN'] = 'TEST' }

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
      assert_select "#secret-token", count: 1, text: 'TEST'
      assert_select "#repository-#{repository_1.id}", count: 1
      assert_select "#repository-#{repository_2.id}", count: 1
    end
  end

  class ApiTest < WebhooksControllerTest
    setup do
      request.accept = Mime[:json]
      @user = users(:one)
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

    test '#POST create with ping event with valid token' do
      ping_payload = load_data('github_ping.json')
      @request.headers['HTTP_X_GITHUB_EVENT'] = 'ping'
      @request.headers['HTTP_X_HUB_SIGNATURE'] = build_signature_for(ping_payload)

      assert_difference 'Event.count', 2 do
        assert_difference 'Repository.count', 1 do
          post :create, params: ping_payload
          assert_response :success

          # The second request is made to make sure to not duplicate the repository
          post :create, params: ping_payload
          assert_response :success
        end
      end

      assert_equal 186853261, json_body['external_id']
      assert_equal 'Octocoders/Hello-World', json_body['full_name']
      assert_equal 'https://github.com/Octocoders/Hello-World', json_body['html_url']
    end

    test '#POST create with issue event with valid token' do
      payload = load_data('issue_event.json')
      @request.headers['HTTP_X_GITHUB_EVENT'] = 'issues'
      @request.headers['HTTP_X_HUB_SIGNATURE'] = build_signature_for(payload)

      assert_difference 'IssueEvent.count', 1 do
        assert_difference 'Repository.count', 1 do
          post :create, params: payload
          assert_response :success
        end
      end
    end

    private

    def build_signature_for(body)
      'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], body.to_param)
    end
  end
end
