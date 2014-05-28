class AppAdmin::MetaKeyDefinitionsController < AppAdmin::BaseController
  before_action :find_meta_context, only: [:edit, :update, :new, :create, :destroy]

  def edit
    @meta_key_definition = @meta_context.meta_key_definitions.find(params[:id])
  end

  def update
    @meta_key_definition = @meta_context.meta_key_definitions.find(params[:id])
    @meta_key_definition.update(meta_key_definition_params)

    redirect_to edit_app_admin_meta_context_url(@meta_context), flash: {success: 'The Meta Key Definition has been updated'}
  end

  def new
    @meta_key_definition = MetaKeyDefinition.new
    @meta_key_definition.meta_context = @meta_context
  end

  def create
    @meta_context.meta_key_definitions << MetaKeyDefinition.create(meta_key_definition_params)

    redirect_to edit_app_admin_meta_context_url(@meta_context), flash: {success: "A new meta key definition has been created"}
  end

  def destroy
    @meta_key_definition = MetaKeyDefinition.find(params[:id])
    @meta_context.meta_key_definitions.delete(@meta_key_definition)

    redirect_to edit_app_admin_meta_context_path(@meta_context), flash: {success: "The meta key definition has been deleted from the <em>#{@meta_context.name}</em> context".html_safe}
  end

  private

  def meta_key_definition_params
    params.require(:meta_key_definition).permit!
  end

  def find_meta_context
    @meta_context = MetaContext.find(params[:meta_context_id])
  end
end
