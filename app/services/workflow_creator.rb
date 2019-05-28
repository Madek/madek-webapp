class WorkflowCreator
  def initialize(attrs, user)
    @attrs = attrs
    @user = user
  end

  def call
    workflow = Workflow.new(@attrs)
    workflow.creator = @user
    workflow.owners << @user
    workflow.collections << Collection.new(creator: @user,
                                           responsible_user: @user,
                                           is_master: true)
    ActiveRecord::Base.transaction do
      workflow.save!
      MetaDatum::Text.create!(
        collection: workflow.master_collection,
        meta_key_id: 'madek_core:title',
        created_by: @user,
        string: workflow.name)
    end
  end
end
