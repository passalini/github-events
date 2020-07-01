class EventsController < ApplicationController
  respond_to :json

  before_action :verify_signature!, only: :create
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @events = IssueEvent.where(external_id: params[:issue_id])
    respond_with_paginated(@events)
  end

  def create
    set_repository!
    @repository.events.create!(event_params)
    render json: @repository
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

  def verify_signature!
    github_signature = request.env['HTTP_X_HUB_SIGNATURE']
    render json: 'Bad signature', status: :unauthorized if github_signature.blank? || !validate_signature(github_signature)
  end

  def validate_signature(github_signature)
    return unless ENV['SECRET_TOKEN']

    request.body.rewind
    payload_body = request.body.read
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
    Rack::Utils.secure_compare(signature, github_signature)
  end

  def set_repository!
    @repository = Repository.find_or_initialize_by(external_id: repository_params.delete(:id))
    return unless @repository.new_record?

    @repository.assign_attributes(repository_params)
    @repository.save
  end

  def repository_params
    params.require(:repository).permit(:id, :full_name, :description, :html_url)
  end

  def event_params
    attrs = { kind: request.env['HTTP_X_GITHUB_EVENT'], payload: params.permit!.to_h }

    if attrs[:kind] == "issues"
      attrs.merge!({
        external_id: params.fetch(:issue, {}).fetch(:id, nil),
        type: 'IssueEvent'
      })
    end

    attrs
  end
end
