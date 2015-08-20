module Concerns
  module MetaData
    extend ActiveSupport::Concern

    def meta_key_id_param(parameters = params)
      parameters.require(:_key)
    end

    def type_param(parameters = params)
      parameters.require(:_value).require(:type)
    end

    def value_param(parameters = params)
      parameters.require(:_value).fetch(:content)
    end

    def value_param_for_update(type)
      if ['MetaDatum::Text', 'MetaDatum::TextDate'].include? type
        raise_if_all_blanks_or_return_unchanged value_param
      else
        value_param
      end
    end

    def raise_if_all_blanks_or_return_unchanged(array)
      array
        .tap do |vals|
          if vals.all?(&:blank?) \
            or vals.all? { |v| v.match Madek::Constants::WHITESPACE_REGEXP }
            raise ActionController::ParameterMissing, 'All values are blank!'
          end
        end
    end

    def constantize_type_param(meta_datum_type)
      begin
        meta_datum_type.constantize
      rescue NameError
        raise Errors::InvalidParameterValue
      end
    end
  end
end
