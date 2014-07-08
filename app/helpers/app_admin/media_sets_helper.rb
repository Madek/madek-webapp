module AppAdmin::MediaSetsHelper
  def active_context_for_media_set?(media_set, context)
    individual_contexts = media_set.individual_and_inheritable_contexts
      
    individual_contexts.each do |individual_context|
      return context == individual_context && media_set.individual_contexts.include?(individual_context)
    end
    false
  end
end
