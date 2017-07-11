module Presenters
  module MetaData
    class MetaDataEdit < Presenters::Shared::AppResourceWithUser

      def meta_datum_by_meta_key_id
        @meta_datum_by_meta_key_id ||=
          Hash[
            fetch_usable_meta_data.map do |meta_datum|
              [
                meta_datum.meta_key_id,
                Presenters::MetaData::MetaDatumEdit.new(meta_datum, @user)
              ]
            end
          ]
      end

      private

      def usable_vocabularies_for_user
        auth_policy_scope(
          @user, Vocabulary.all, VocabularyPolicy::UsableScope)
          .sort_by
      end

      def fetch_usable_meta_data
        parent_resource_type = @app_resource.class.name.underscore
        MetaKey
          .where("is_enabled_for_#{parent_resource_type.pluralize}" => true)
          .joins(:vocabulary)
          .where(vocabularies: { id: usable_vocabularies_for_user.map(&:id) })
          .map do |key|
            existing_datum = @app_resource.meta_data.where(meta_key: key).first
            if existing_datum.present?
              existing_datum
            else # prepare a new, blank instance to "fill out":
              md_klass = key.meta_datum_object_type.constantize
              md_klass.new(
                meta_key: key,
                parent_resource_type => @app_resource)
            end
          end
      end
    end
  end
end
