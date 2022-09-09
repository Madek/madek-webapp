class MetaDatumPolicy < DefaultPolicy
  def show?
    # visibility of MD is dependent on record *and* vocabulary!
    return false unless Pundit.policy!(user, record.media_entry).show?
    if logged_in?
      vocabulary.viewable_by_user?(user)
    else
      vocabulary.viewable_by_user_or_public?(user)
    end
  end

  def new? # just the generic form, `create?` is the important check!
    logged_in?
  end

  def mutate?
    logged_in? \
      and media_resource.editable_by_user?(user) \
      and vocabulary.usable_by_user?(user)
  end

  alias_method :create?, :mutate?
  alias_method :edit?, :mutate?
  alias_method :update?, :mutate?
  alias_method :destroy?, :mutate?

  private

  def vocabulary
    record.meta_key.vocabulary
  end

  def media_resource
    record.media_entry or
      record.collection
  end
end
