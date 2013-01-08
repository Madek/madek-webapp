module VisualizationHelper

  def vis_json resources

    resources = resources.with_graph_size_and_title

    resources.as_json(only: [:id,:type,:size,:meta_datum_title,:user_id])

  end

end
