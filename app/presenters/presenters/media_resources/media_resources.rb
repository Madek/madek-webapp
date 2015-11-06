module Presenters
  module MediaResources

    # NOTE: This is a list of anything that inherits from MediaResources,
    #       *not* the (shared) base class MediaResource!

    class MediaResources < Presenter
      include Presenters::Shared::Concerns::PaginationInfo

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
        }).merge(list_conf.deep_symbolize_keys)
          .merge(filter: parse_json_filters(list_conf['filter']))

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
        return unless (@config && @config[:for_url])

        cur_path = @config[:for_url][:path]
        cur_query = @config[:for_url][:query]
        cur_conf = @config.except(:for_url)

        prev_conf = offset_pagination(cur_conf, -1)
        next_conf = offset_pagination(cur_conf, 1)

        prev_link = if (cur_conf[:page].to_i > 1)
                      link_with_new_params(cur_path, cur_query, list: prev_conf)
                    end

        next_link = if (select(@given_resources, next_conf).first.present?)
                      link_with_new_params(cur_path, cur_query, list: next_conf)
                    end

        { prev: prev_link, next: next_link }
      end

      private

      def offset_pagination(conf, offset)
        ({}).merge(conf).merge(page: conf[:page].to_i + offset)
      end

      def link_with_new_params(path, old, new)
        path + '?' + ({}).merge(old).merge(new).to_query
      end

      def parse_json_filters(string)
        begin
          JSON.parse(string).deep_symbolize_keys
        rescue
          {}
        end
      end

      def select(resources, config)
        unless active_record_collection?(resources)
          fail 'TypeError! not an AR Collection/Relation!'
        end

        resources
          .viewable_by_user_or_public(@user)
          .filter(config[:filter])
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
