module Concerns
  module KeywordTermRoutingHelper

    private

    def keyword_term_param(path: request.original_fullpath, action: 'terms')
      # NOTE: Rails' routing normalizes paths, which may include the term,
      # e.g. double slashes in terms are lost in `params.require(:term)`!
      CGI.unescape(path.sub("/vocabulary/#{meta_key_id_param}/#{action}/", ''))
    end

    def meta_key_id_param
      params.require(:meta_key_id)
    end

  end
end
