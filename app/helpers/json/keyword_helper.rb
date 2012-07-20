module Json
  module KeywordHelper

    def hash_for_keyword(keyword, with = nil)
      h = {
        id: keyword.meta_term_id,
        label: keyword.to_s
      }
      
      if with ||= nil
        ## WITH MINE
        if with[:mine]
          h[:yours] = (current_user == keyword.user)
        end
        
        ## WITH CREATED AT
        if with[:created_at]
          h[:created_at] = keyword.created_at
        end
        
        ## WITH COUNT
        if with[:count]
          h[:count] = Keyword.where(:meta_term_id => keyword.meta_term_id).count
        end
      end
      
      h
    end

  end
end
      
