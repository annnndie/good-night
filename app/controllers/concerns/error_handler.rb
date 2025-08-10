module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  end

  private

  def handle_parameter_missing(exception)
    render json: {
      errors: "Parameter is required"
    }, status: :bad_request
  end

  def handle_record_invalid(exception)
    render json: {
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def handle_record_not_found(exception)
    model_name = exception.model.underscore.humanize
    render json: {
      errors: "#{model_name} not found"
    }, status: :not_found
  end
end
