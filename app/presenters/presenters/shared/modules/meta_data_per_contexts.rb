module Presenters
  module Shared
    module Modules
      module MetaDataPerContexts
        extend ActiveSupport::Concern

        included do

          private

          def build_meta_data_context(app_resource, user, context)
            # NOTE: cant just `JOIN` them all together like in `by_vocabulary`,
            #   because there we can sort later
            #   by vocab/key (which have 1:1 relation).
            #   Here we need to do Context -> c_key -> MK -> MD.
            Pojo.new(
              context: Presenters::Contexts::ContextCommon.new(context),
              meta_data: _presenterify_key_values(
                app_resource, user, context)
            )
          end

          def _presenterify_key_values(app_resource, user, context)
            meta_data_for_context(app_resource, user, context).map do |pair|
              Pojo.new(
                context_key: Presenters::ContextKeys::ContextKeyCommon.new(
                  pair[:context_key]),
                meta_datum: Presenters::MetaData::MetaDatumCommon.new(
                  pair[:meta_datum], user)
              )
            end
          end

          def meta_datum_for_context_key(app_resource, user, context_key)
            visible = context_key.meta_key.vocabulary.viewable_by_user?(user)
            return nil unless visible

            md = app_resource.meta_data.find_by(meta_key: context_key.meta_key)
            return nil unless md

            {
              context_key: context_key,
              meta_datum: md
            }
          end

          def meta_data_for_context(app_resource, user, context)
            context.context_keys.map do |c_key|
              meta_datum_for_context_key(app_resource, user, c_key)
            end.compact
          end
        end
      end
    end
  end
end
