require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    request.accept = Mime[:json]
    @user = users(:one)
    ENV['SECRET_TOKEN'] = 'TEST'
  end

  test '#GET index' do
    event_2 = events(:two)
    event_3 = events(:three)

    get :index, params: { issue_id: 1, per_page: 1, page: 1 }

    assert_response :success
    assert_equal 1, json_body['current_page']
    assert_equal 2, json_body['total_pages']
    assert_equal 2, json_body['total_count']
    assert_equal 1, json_body['per_page']
    assert_equal 1, json_body['events'].count
    assert_equal event_3.id, json_body['events'].first['id']
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
