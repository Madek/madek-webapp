ActiveAdmin.register_page "Mapping" do
  menu :parent => "Meta"

  content do
    @graph = MetaKeyDefinition.keymapping_graph
    image_tag "/#{@graph}", {:style => "width: 100%; height: auto;"}
  end
end
