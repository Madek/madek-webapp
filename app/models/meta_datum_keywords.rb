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
    #user = media_resource.editors.latest || (media_resource.respond_to?(:user) ? media_resource.user : nil)
    user = media_resource.edit_sessions.first.try(:user) || (media_resource.respond_to?(:user) ? media_resource.user : nil)
    new_keywords = Array(new_value).map do |v|
        if false #FIXME dup keywords# user.nil? and media_resource.is_a?(Snapshot)
          # the Snapshot has just been created, so we take exactly the MediaEntry's keyword
          Keyword.find(v)
        else
          if v.is_a?(Fixnum) or (v.respond_to?(:is_integer?) and v.is_integer?)
            # FIXME recover exising record? Keyword.where(:meta_term_id => v, :id => value_was).first || Keyword.new(:meta_term_id => v, :user => user)
            # FIXME this only works for existing meta_datum ??
            Keyword.where(:meta_term_id => v, :meta_datum_id => self.id).first
            #keywords.build(:meta_term => MetaTerm.find_by_id(v), :user => user)
            #Keyword.new(:meta_term_id => v, :user => user)
          else
            # 2210
            #conditions = [[]]
            #LANGUAGES.each do |lang|
            #  conditions.first << "#{lang} = ?"
            #  conditions << v
            #end
            #conditions[0] = conditions.first.join(" OR ")
            conditions = {DEFAULT_LANGUAGE => v}
            term = MetaTerm.where(conditions).first
  
            term ||= begin
              h = {}
              LANGUAGES.each do |lang|
                h[lang] = v
              end
              MetaTerm.create(h)
            end
            
            #keywords.build(:meta_term => term, :user => user)
            Keyword.new(:meta_term_id => term.id, :user => user)
          end
        end
    end
    #self.keywords.clear # FIXME this will reset the created_at ???
    self.keywords << new_keywords
  end

end
