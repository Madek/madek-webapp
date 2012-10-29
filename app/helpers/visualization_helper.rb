module VisualizationHelper

  def vis_json resources

    original_resources = resources

    # this is probably the worst query in the whole application (since it
    # uses all the other horrible ones inside its subqueries); but it doesn't
    # perform bad; once it does, compute the size on the client

    resources = resources.
      select("count(arc_id) as size, media_resources.*, MD.title as meta_datum_title").
      joins("LEFT OUTER JOIN ( #{conditional_descendants_cte_query(original_resources)} ) descendants ON media_resources.id = descendants.media_resource_id").
      # use a left outer join in the title true
      joins(" LEFT OUTER JOIN 
        (SELECT meta_data.media_resource_id as media_resource_id, meta_data.string as title
            FROM meta_data 
            INNER JOIN meta_keys ON meta_keys.id = meta_data.meta_key_id 
            WHERE meta_keys.label = 'title'
            ) MD ON  MD.media_resource_id = media_resources.id").
      group("media_resources.id, meta_datum_title") # note that yet alone id is unique

    resources.as_json(only: [:id,:type,:size,:meta_datum_title,:user_id])

  end

  # this query can be used to compute the relative size of a media-set in a
  # collection of resources which is itself defined by a query
  def conditional_descendants_cte_query resources = nil
     
    condition = resources ? "AND child_id in ( #{resources.select('media_resources.id').to_sql} )" : ""

    " WITH RECURSIVE triple(p,c,media_resource_id) as
      (
        SELECT parent_id as p, child_id as c, media_resources.id as media_resource_id 
          FROM media_resource_arcs, media_resources
          WHERE parent_id = media_resources.id
          #{condition}
        UNION
        SELECT parent_id as p, child_id as c, media_resource_id FROM triple, media_resource_arcs
          WHERE parent_id = triple.c
          #{condition}
      ) 
      SELECT id as arc_id, media_resource_id FROM media_resource_arcs, triple
        WHERE media_resource_arcs.parent_id = triple.p
        AND media_resource_arcs.child_id = triple.c 
    "
  end

end
