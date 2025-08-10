class ApplicationController < ActionController::API
  include ErrorHandler
  include Pagy::Backend

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

  def render_json(status, results = nil)
    render json: (results.present? ? { data: results } : {}), status: status
  end

  def render_json_with_page(status, results = {})
    data = {
      current_page: @pagy.page,
      total_pages: @pagy.pages,
      total_items: @pagy.count
    }.merge(results)

    render json: { data: data }, status: status
  end
end
