class WebhooksController < ApplicationController
  respond_to :html, :json

  before_action :verify_token!, only: :create
  before_action :authenticate_user!, only: :index
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @repositories = Repository.all
    @secret_token = current_user.secret_token
  end

  def create
    set_repository!
    @repository.events.create!(event_params)
    render json: @repository
  end

  private

  def verify_token!
    secret_token = request.env['HTTP_X_HUB_SIGNATURE']

    if secret_token
      email = Base64.decode64(secret_token)
      user = User.try(:find_by, email: email) if email.match(URI::MailTo::EMAIL_REGEXP)
    end

    render json: 'Bad credentials', status: :unauthorized if secret_token.blank? || user.blank?
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
