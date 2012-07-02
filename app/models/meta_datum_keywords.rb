# -*- encoding : utf-8 -*-
class MetaDatumKeywords < MetaDatum

  has_many :keywords, foreign_key: :meta_datum_id

  def to_s
    deserialized_value.map(&:to_s).join("; ")
  end

  def value
    keywords
  end

  def value=(new_value)
    user = media_resource.edit_sessions.first.try(:user) || (media_resource.respond_to?(:user) ? media_resource.user : nil)
    binding.pry
    new_keywords = Array(new_value).map do |v|
      if v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
        binding.pry
        Keyword.where(:meta_term_id => v, :meta_datum_id => self.id).first
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

        binding.pry
        Keyword.new(:meta_term_id => term.id, :user => user)
      end
    end
    #self.keywords.clear # FIXME this will reset the created_at ???
    binding.pry
    self.keywords << new_keywords
  end

end
