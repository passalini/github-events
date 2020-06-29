class WebhooksController < ApplicationController
  respond_to :html, :json
  before_action :authenticate_user!, only: :index
  skip_before_action :verify_authenticity_token, only: :create

  def index
    @hooks = Hook.all
  end

  def create
    if ping_request?
      hook = Hook.find_or_initialize_by(external_id: ping_params.delete(:id))
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
end
