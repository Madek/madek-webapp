class KeywordPolicy < DefaultPolicy
  def index?
    record.all? do |keyword|
      keyword
        .meta_key
        .vocabulary
        .viewable_by_user?(user)
    end
  end
end
