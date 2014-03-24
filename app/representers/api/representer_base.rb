class API::RepresenterBase < Roar::Decorator
  include ActionView::Helpers
  include Roar::Representer::JSON::HAL

  def as_json_with_curies
    _map = as_json_without_curies.symbolize_keys
    if _map[:'_links']
      _map[:'_links'].merge!({curies: [{name: "madek", href: "/public/api_docs/{rel}", templated: true}]})
    else
      _map[:'_links']= ({curies: [{name: "madek", href: "/public/api_docs/{rel}", templated: true}]})
    end
    _map
  end

  alias_method_chain  :as_json, :curies

  link 'madek:'  do api_path end

  property :timstamps, writer: lambda{ |doc,args|
    if respond_to? :created_at
      doc[:created_at]= created_at.iso8601
    end
    if respond_to? :updated_at 
      doc[:updated_at]= updated_at.iso8601
    end
  }
 

end
