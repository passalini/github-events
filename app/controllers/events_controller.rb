class EventsController < ApplicationController
  respond_to :json

  def index
    @events = IssueEvent.where(external_id: params[:issue_id])
    respond_with_paginated(@events)
  end

  private

  def respond_with_paginated(collection)
    collection = collection.page(params[:page] || 1).
      per(params[:per_page] || 10).
      order(created_at: :desc)

    data = {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }

    data[collection.table_name] = collection
    render json: data
  end
end
