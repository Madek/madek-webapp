class Admin::MetaKeyDefinitionsController < Admin::AdminController

  def index
    @meta_key_definitions = MetaKeyDefinition.all
  end

  def edit
    @meta_key_definition = MetaKeyDefinition.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update 
    @meta_key_definition = MetaKeyDefinition.find(params[:id])
    @meta_key_definition.update_attributes(params[:meta_key_definition])

    respond_to do |format|
      format.js { render partial: "show", locals: {meta_key_definition: @meta_key_definition} }
    end

  end

end
