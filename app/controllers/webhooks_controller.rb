class WebhooksController < ApplicationController
  before_action :authenticate_user!

  def index
    @repositories = Repository.all
    @secret_token = ENV['SECRET_TOKEN']
  end
end
