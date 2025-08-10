class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    user_id = request.headers["X-User-ID"]
    @current_user = User.find_by(id: user_id) if user_id.present?

    unless @current_user
      render json: { errors: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
