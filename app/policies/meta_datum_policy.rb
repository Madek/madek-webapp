class MetaDatumPolicy < DefaultPolicy
  def show?
    if logged_in?
      media_resource.viewable_by_user?(user) \
        and vocabulary.viewable_by_user?(user)
    else
      media_resource.viewable_by_public? \
        and vocabulary.viewable_by_public?
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
      record.collection or
      record.filter_set
  end
end
