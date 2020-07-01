class WebhooksController < ApplicationController
  respond_to :html, :json

  before_action :verify_signature!, only: :create
  before_action :authenticate_user!, only: :index
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @repositories = Repository.all
    @secret_token = ENV['SECRET_TOKEN']
  end

  def create
    set_repository!
    @repository.events.create!(event_params)
    render json: @repository
  end

  private

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
