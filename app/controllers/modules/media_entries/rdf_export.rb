module Modules
  module MediaEntries
    module RdfExport
      extend ActiveSupport::Concern

      def rdf_export
        entry = get_authorized_resource
        @get = Presenters::MediaEntries::MediaEntryRdfExport.new(entry, current_user)
        as_plain_text = params.keys.include?('txt')

        respond_to do |format|
          format.rdf do
            if as_plain_text
              render(plain: @get.rdf_xml.to_s, content_type: "text/plain")
            else
              response.headers['Content-Disposition'] = "attachment; filename=#{entry.id}.rdf"
              render(xml: @get.rdf_xml, disposition: 'attachment')
            end
          end

          format.ttl do
            if as_plain_text
              render(plain: @get.rdf_turtle.to_s, content_type: "text/plain")
            else
              response.headers['Content-Disposition'] = "attachment; filename=#{entry.id}.ttl"
              render(body: @get.rdf_turtle.to_s, disposition: 'attachment')
            end
          end

          format.json do
            if as_plain_text
              render(plain: JSON.pretty_generate(@get.json_ld), content_type: "text/plain")
            else
              response.headers['Content-Disposition'] = "attachment; filename=#{entry.id}.ld.json"
              render(json: @get.json_ld, disposition: 'attachment')
            end
          end
        end
      end

    end
  end
end
