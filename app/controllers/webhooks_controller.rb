class WebhooksController < ApplicationController
  respond_to :html, :json
  before_action :verify_token!, only: :create
  before_action :authenticate_user!, only: :index
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @hooks = current_user.hooks
    @secret_token = current_user.secret_token
  end

  def create
    if ping_request?
      hook = current_user.hooks.find_or_initialize_by(external_id: ping_params.delete(:id))
      hook.assign_attributes(ping_params)
      hook.save!

      render json: hook
    end
  end

  private

  def ping_params
    permitted = params.require(:hook).permit(:type, :name, :active, :url, :id)
    permitted[:hook_type] = permitted.delete(:type)
    permitted
  end

  def ping_request?
    params.include?(:zen)
  end

  def verify_token!
    secret_token = request.env['HTTP_X_HUB_SIGNATURE']

    if secret_token
      email = Base64.decode64(secret_token)
      @current_user = User.try(:find_by, email: email) if email.match(URI::MailTo::EMAIL_REGEXP)
    end

    render json: 'Bad credentials', status: :unauthorized if secret_token.blank? || current_user.blank?
  end
end
