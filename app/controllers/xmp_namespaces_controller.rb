class XmpNamespacesController < ApplicationController

  def index
    skip_authorization
    respond_with(@get = Presenters::XmpNamespaces::XmpNamespacesIndex.new)
  end

  def show
    skip_authorization
    namespace = XmpNamespace.managed.find_by!(prefix: params.require(:prefix))

    respond_to do |format|
      format.html do
        @get = Presenters::XmpNamespaces::XmpNamespaceShow.new(namespace, current_user)
      end
      format.xmp do
        send_data(XmpTemplate.new(namespace.xmp_properties).to_xml,
                  filename: "#{namespace.prefix}.xmp", type: :xmp)
      end
    end
  end
end
