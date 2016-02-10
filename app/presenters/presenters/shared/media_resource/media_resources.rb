module Presenters
  module Shared
    module MediaResource
      # NOTE: This is a list of anything that inherits from MediaResources,
      #       *not* the (shared) base class MediaResource!
      class MediaResources < Presenter
        attr_reader :resources, :pagination, :config

        DEFAULT_CONFIG = { page: 1, per_page: 12, order: 'created_at DESC' }

        def initialize(scope, user, list_conf: nil)
          fail 'missing config!' unless list_conf
          @user = user
          @scope = scope
          @config = DEFAULT_CONFIG.merge(list_conf) # combine with given config…
            .instance_eval do |conf| # coerce types…
              conf.merge(page: conf[:page].to_i, per_page: conf[:per_page].to_i)
            end

          init_resources_and_pagination(@scope, @config)
        end

        # TODO: implement count up to 1000
        # def total_count
        #   @selected_resources.total_count
        # end

        def any?
          @resources.first.present?
        end

        def empty?
          not any?
        end

        def dynamic_filters
          # NOTE: scope is pre-filtered, but not paginated!
          scope = @config[:filter] ? @scope.filter_by(@config[:filter]) : @scope
          tree = @config[:dyn_filter]
          Presenters::Shared::DynamicFilters.new(@user, scope, tree).list
        end

        private

        # NOTE: optimized pagination, no extra queries!
        def init_resources_and_pagination(resources, config)
          # apply pagination, but select 1 "extra",
          resources_and_next = select(
            resources,
            config,
            limit: (config[:per_page] + 1),
            offset: (config[:page] - 1) * config[:per_page])
          # if there is an "extra", it means there is a next page
          has_next_page = resources_and_next[config[:per_page]].present?
          # determine presenter from relation model (before it's coerced .to_a)
          presenter = presenter_by_class(resources_and_next.model)
          # presenterify without the "extra"
          @resources = presenterify(
            resources_and_next.slice(0, config[:per_page]), presenter)
          @pagination = build_pagination(config, has_next_page)
        end

        def build_pagination(config, has_next_page)
          { # each key is nil or contains the params needed to build link to page
            prev: ((config[:page] > 1) ? { page: (config[:page] - 1) } : nil),
            next: (has_next_page ? { page: (config[:page] + 1) } : nil)
          }
        end

        def select(resources, config, pagination)
          unless active_record_collection?(resources)
            fail 'TypeError! not an AR Collection/Relation!'
          end

          resources
            .filter_by(config[:filter] || {})
            .reorder(config[:order])
            .limit(pagination[:limit])
            .offset(pagination[:offset])
        end

        def presenterify(resources, determined_presenter = nil)
          resources.map do |resource|
            # if no presenter given, need to check class of every member!
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
