module Presenters
  module Shared
    module MediaResource
      # NOTE: This is a list of anything that inherits from MediaResources,
      #       *not* the (shared) base class MediaResource!

      # - everything in @conf are *shared* params (part of the URL)
      # - `can_filter`: in here it signifies if the scope *can* be filtered at all,
      #   in the view it determines if filtering is *allowed*.
      # - list_conf: the 'listing config' (shared with client via params)
      #   its' defaults are below:

      DEFAULT_LIST_CONFIG = {
        page: 1, per_page: 12, order: 'created_at DESC', # pagination
        show_filter: false # show filtering sidebar? (loads DynFilters!)
      }

      class MediaResources < Presenter
        include Presenters::Shared::MediaResource::Modules::IndexPresenterByClass

        attr_reader :resources, :pagination, :has_user, :can_filter, :type
        attr_accessor :try_collections
        attr_accessor :disable_file_search
        attr_reader :only_filter_search
        attr_reader :json_path

        def initialize(
            scope, user, list_conf: nil, item_type: nil,
            can_filter: true,
            with_count: true, load_meta_data: false,
            only_filter_search: false,
            disable_file_search: false,
            json_path: nil,
            content_type: nil)
          fail 'missing config!' unless list_conf or list_conf[:for_url].present?
          @user = user
          @scope = scope
          @type = item_type || scope.model.name.pluralize
          # enable interaction if user logged in and not explictly turned of
          @has_user = true if @user.present?
          # can the given scope be filtered? (`#filter_by`)
          @can_filter = can_filter
          @conf = build_config(list_conf)
          @with_count = with_count
          @load_meta_data = load_meta_data
          @try_collections = false
          @only_filter_search = only_filter_search
          @disable_file_search = disable_file_search
          @json_path = json_path
          @content_type = content_type
          init_resources_and_pagination(@scope, @conf)
        end

        def config
          @conf.to_h
        end

        def any?
          # NOTE: need to ask the *unpaginated* BUT *filtered* scope!
          # NOTE: #any? triggers a weird Arel bug, do it manually:
          _total_count > 0
        end

        def empty?
          not any?
        end

        def content_type
          return unless @content_type
          @content_type.name
        end

        def dynamic_filters
          return unless @conf[:sparse_filter]
          return if @only_filter_search
          return unless @conf[:show_filter] # and @type == 'MediaEntries'
          # NOTE: scope is pre-filtered, but not paginated!
          scope = \
            @conf[:filter] ? @scope.filter_by(@user, @conf[:filter]) : @scope
          tree = @conf[:dyn_filter]
          Presenters::Shared::DynamicFilters.new(
            @user, scope, tree, @conf[:filter]
          )
        end

        def route_urls
          %w(batch_edit_meta_data_by_context_media_entries
             batch_edit_meta_data_by_context_collections
             batch_destroy_resources
             session_list_config
             batch_edit_permissions_media_entries
             batch_edit_permissions_collections
             filter_sets
             batch_update_transfer_responsibility_media_entries
             batch_update_transfer_responsibility_collections).map do |path_name|
               [path_name, send("#{path_name}_path")]
          end.to_h
        end

        def clipboard_url
          my_dashboard_section_path(:clipboard)
        end

        private

        def build_config(list_conf)
          DEFAULT_LIST_CONFIG.merge(list_conf) # combine with given config…
            .instance_eval do |conf| # coerce types…
              conf.merge(page: conf[:page].to_i, per_page: conf[:per_page].to_i)
            end
        end

        # NOTE: optimized pagination, no extra queries!
        def init_resources_and_pagination(resources, config)
          # determine presenter from relation/scope model
          presenter = presenter_by_class(resources.model)

          # apply pagination and select resources
          # NOTE: total_count could be expensive, so it's optional!
          @selected_resources = select_resources(resources, config)
          total_count = _total_count if @with_count

          # apply pagination, but select "1 extra" (for building cheap pagination)
          ordered_resources = @selected_resources.custom_order_by(
            config[:order])
          resources_page_and_next = ordered_resources
            .limit(config[:per_page] + 1)
            .offset((config[:page] - 1) * config[:per_page])

          # presenterify without the "1 extra"
          @resources = presenterify(
            resources_page_and_next.slice(0, config[:per_page]), presenter)

          # if there is "1 extra", there is a next page:
          has_next_page = resources_page_and_next[config[:per_page]].present?
          @pagination = build_pagination(config, has_next_page, total_count)
        end

        def select_resources(resources, config)
          unless active_record_collection?(resources)
            fail 'TypeError! not an AR Collection/Relation!'
          end
          resources.filter_by(@user, config[:filter] || {})
        end

        def _total_count
          # PERF: memo the count, it's expensive!
          return @_total_count if @_total_count

          # FIXME: fails non-deterministally, workaround by retrying…
          @_total_count = _lol_rails_try_n_times(10) do
            @selected_resources.count
          end
        end

        def presenterify(resources, determined_presenter = nil)
          resources.map do |resource|
            # if no presenter given, need to check class of every member!
            presenter = determined_presenter || presenter_by_class(resource.class)
            presenter.new(
              resource,
              @user,
              load_meta_data: @load_meta_data,
              list_conf: @conf)
          end
        end

        def build_pagination(config, has_next_page, count)
          { # each key is nil or contains the params needed to build link to page
            prev: ((config[:page] > 1) ? { page: (config[:page] - 1) } : nil),
            next: (has_next_page ? { page: (config[:page] + 1) } : nil),
            total_count: count, # is optional, may be nil
            total_pages: (count.to_f / config[:per_page]).ceil
          }
        end

        def active_record_collection?(obj)
          /^ActiveRecord::((Association|)Relation|Associations::CollectionProxy)$/
          .match(obj.class.name)
        end

        def _lol_rails_try_n_times(max_tries, &_block)
          result = nil
          tries = 1
          while !result && tries <= max_tries
            begin
              result = yield
            rescue => e
              raise e if tries >= max_tries # give up and throw
            end
            sleep ((1 + rand) / 10) # wait between 100 and 200ms
            tries += 1
          end
          result
        end
      end
    end
  end
end
