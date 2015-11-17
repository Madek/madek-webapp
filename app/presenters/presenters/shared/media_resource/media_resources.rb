module Presenters
  module Shared
    module MediaResource
      # NOTE: This is a list of anything that inherits from MediaResources,
      #       *not* the (shared) base class MediaResource!
      class MediaResources < Presenter
        attr_reader :resources, :config

        # NOTE: for pagination conf, see </config/initializers/kaminari_config.rb>
        def initialize(resources, user, list_conf: nil)
          fail 'missing config!' unless list_conf

          @user = user
          @given_resources = resources
          @config = ({
            order: nil,
            page: 1,      # nil always means 'first page'
            per_page: 12  # default for this presenter
          }).merge(list_conf)

          @selected_resources = select(@given_resources, @config)
          @resources = presenterify(@selected_resources)
        end

        # TODO: implement count up to 1000
        # def total_count
        #   @selected_resources.total_count
        # end
        #

        def any?
          @selected_resources.first.present?
        end

        def empty?
          not any?
        end

        def pagination
          return unless @config.fetch(:for_url, {}).present?

          path = @config[:for_url][:path]
          query = @config[:for_url][:query]
          prev_page = @config[:page].to_i - 1
          next_page = @config[:page].to_i + 1

          prev_link = if (prev_page > 0)
                        set_params_for_url(path, query, list: { page: prev_page })
                      end

          # binding.pry

          # NOTE: **extra query** here to figure out if there is a 'next' page:
          next_page_conf = @config.deep_merge(page: next_page)
          has_next_page = select(@given_resources, next_page_conf).first.present?

          next_link = if (has_next_page)
                        set_params_for_url(path, query, list: { page: next_page })
                      end

          { prev: prev_link, next: next_link }
        end

        private

        def offset_pagination(conf, offset)
          { per_page: conf[:per_page], page: conf[:page].to_i + offset }
        end

        def set_params_for_url(path, old_params, new_params)
          path + '?' + old_params.deep_merge(new_params).to_query
        end

        def select(resources, config)
          unless active_record_collection?(resources)
            fail 'TypeError! not an AR Collection/Relation!'
          end

          resources
            .viewable_by_user_or_public(@user)
            .filter_by(config[:filter] || {})
            .reorder(config[:order])
            .page(config[:page])
            .per(config[:per_page])
        end

        def presenterify(resources)
          # for "normal" relations we can get the type for whole list,
          # but for 'MediaResources' we need to check every member
          determined_presenter = presenter_by_class(resources.model)
          resources.map do |resource|
            presenter = determined_presenter || presenter_by_class(resource.class)
            presenter.new(resource, @user)
          end
        end

        def presenter_by_class(klass)
          case klass.name
          when 'MediaEntry' then Presenters::MediaEntries::MediaEntryIndex
          when 'Collection' then Presenters::Collections::CollectionIndex
          when 'FilterSet' then Presenters::FilterSets::FilterSetIndex
          when 'MediaResource' then nil
          else
            raise 'Unknown resource type!'
          end
        end

        def active_record_collection?(obj)
          /^ActiveRecord::((Association|)Relation|Associations::CollectionProxy)$/
          .match(obj.class.name)
        end
      end
    end
  end
end
