module Concerns
  module MetaData
    module SanitizeValue
      # val can be a string (text or uuid) or an array of strings (uuids).
      # In the case of uuids, the corresponding models have to be initialized.
      def with_sanitized(val)
        vals = (val.is_a?(Array) ? val : [val])
        sanitized_value = \
          extract_from_array_if_necessary \
            reject_blanks_and_modelify_if_necessary(vals)
        raise 'Use safe value via block!' unless block_given?
        yield(sanitized_value)
        # TODO: return safe_new_value
      end

      private

      def reject_blanks_and_modelify_if_necessary(vals)
        vals
          .reject(&:blank?)
          .map { |v| modelify_if_necessary(v) }
      end

      def modelify_if_necessary(val)
        if ApplicationHelper.ar_collection_proxy?(self.value)
          self.value.klass.find(val)
        else
          val
        end
      end

      def extract_from_array_if_necessary(val)
        need_to_extract_from_array? ? val.first : val
      end

      def need_to_extract_from_array?
        not ApplicationHelper.ar_collection_proxy?(self.value)
      end
    end
  end
end
