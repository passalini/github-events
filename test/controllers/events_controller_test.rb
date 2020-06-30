require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  test '#GET index' do
    event_2 = events(:two)
    event_3 = events(:three)
    request.accept = Mime[:json]

    get :index, params: { issue_id: 1, per_page: 1, page: 1 }

    assert_response :success
    assert_equal 1, json_body['current_page']
    assert_equal 2, json_body['total_pages']
    assert_equal 2, json_body['total_count']
    assert_equal 1, json_body['per_page']
    assert_equal 1, json_body['events'].count
    assert_equal event_3.id, json_body['events'].first['id']
  end
end
