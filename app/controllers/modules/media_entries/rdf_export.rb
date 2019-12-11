module Modules
  module MediaEntries
    module RdfExport
      extend ActiveSupport::Concern

      def rdf_export
        entry = get_authorized_resource
        @get = Presenters::MediaEntries::MediaEntryRdfExport.new(entry, current_user)

        respond_to do |format|
          format.rdf do
            render(xml: @get.rdf_xml)
          end
          format.ttl do
            if params.keys.include?('txt')
              render(plain: @get.rdf_turtle.to_s, content_type: "text/plain")
            else
              render(body: @get.rdf_turtle.to_s)
            end
          end
          format.json do
            render(json: @get.json_ld)
          end
        end
      end

    end
  end
end
