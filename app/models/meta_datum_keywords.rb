# -*- encoding : utf-8 -*-
class MetaDatumKeywords < MetaDatum

  # NOTE this is defined up in MetaDatum because eager loading
  #has_many :keywords, foreign_key: :meta_datum_id

  def to_s
    value.map(&:to_s).join("; ")
  end

  def value
    keywords
  end

  # TODO this is a insane 
  def value=(new_value)
    user = media_resource.try(:edit_sessions).try(:first).try(:user) || (media_resource.respond_to?(:user) ? media_resource.user : nil)
    new_keywords = Array(new_value).map do |v|
      if UUID_V4_REGEXP.match v 
        k = nil
        k = Keyword.find_by(meta_term_id: v, meta_datum_id: self.id) if self.persisted?
        k ||= Keyword.new(:meta_term_id => v, :user => user)
      elsif v.is_a? Keyword
        Keyword.new(:meta_term => v.meta_term)        
      else
        conditions = {DEFAULT_LANGUAGE => v}
        term = MetaTerm.where(conditions).first

        term ||= begin
                   h = {}
                   LANGUAGES.each do |lang|
                     h[lang] = v
                   end
                   MetaTerm.create(h)
                 end

        Keyword.new(:meta_term_id => term.id, :user => user)
      end
    end
    Keyword.delete(self.keywords - new_keywords)
    self.keywords << (new_keywords - self.keywords)
  end

end
