module DatetimeValidation
  extend ActiveSupport::Concern

  class InvalidDatetimeError < StandardError
    attr_reader :field_name

    def initialize(field_name)
      @field_name = field_name
      super("#{field_name} must be a valid datetime format")
    end
  end

  private

  def validate_datetime_params(params_hash = {})
    params_hash.each do |key, value|
      next if value.blank?

      Time.parse(value.to_s)
    rescue ArgumentError
      raise InvalidDatetimeError, key
    end
  end
end
