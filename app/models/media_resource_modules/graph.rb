module MediaResourceModules
  module Graph
    extend ActiveSupport::Concern

    ### Connected Resources ##################################################
    def connected_resources(media_resource, resource_condition=nil)
      where <<-SQL
        media_resources.id in  (
          (WITH RECURSIVE pair(p,c) AS
          (
            SELECT parent_id as p, child_id as c FROM media_resource_arcs 
              WHERE (parent_id in (#{media_resource.id}) OR child_id in (#{media_resource.id}))
          #{ "AND parent_id in (#{resource_condition.select("media_resources.id").to_sql })" if resource_condition }
          #{ "AND child_id in (#{resource_condition.select("media_resources.id").to_sql})" if resource_condition }
            UNION
              SELECT media_resource_arcs.parent_id as p, media_resource_arcs.child_id as c FROM pair, media_resource_arcs
              WHERE ( 
                media_resource_arcs.parent_id = pair.c
                OR media_resource_arcs.child_id = pair.c
                OR media_resource_arcs.parent_id = pair.p
                OR media_resource_arcs.child_id = pair.p)
          #{ "AND media_resource_arcs.parent_id in (#{resource_condition.select("media_resources.id").to_sql})"  if resource_condition }
          #{ "AND media_resource_arcs.child_id in (#{resource_condition.select("media_resources.id").to_sql})"  if resource_condition }
          )
          SELECT pair.c from pair UNION SELECT pair.p from pair
          )
        )
      SQL
    end


    ### Descendants #######################################

    # set condition must be a query that returns media_resources; 
    # condition is on the inclusion of the arcpoints
    def descendants_and_set(media_set, resource_condition=nil)
      where <<-SQL
    media_resources.id in  (
      (WITH RECURSIVE pair(p,c) AS
      (
        SELECT parent_id as p, child_id as c FROM media_resource_arcs 
          WHERE parent_id in (#{media_set.id})
      #{ "AND parent_id in (#{resource_condition.select("media_resources.id").to_sql })" if resource_condition }
      #{ "AND child_id in (#{resource_condition.select("media_resources.id").to_sql})" if resource_condition }
        UNION
          SELECT media_resource_arcs.parent_id as p, media_resource_arcs.child_id as c FROM pair, media_resource_arcs
          WHERE media_resource_arcs.parent_id = pair.c
      #{ "AND media_resource_arcs.parent_id in (#{resource_condition.select("media_resources.id").to_sql})"  if resource_condition }
      )
      SELECT pair.c from pair
      )
     UNION
    (
      SELECT media_resources.id FROM media_resources WHERE id = #{media_set.id}
    ))
      SQL
    end





    def with_graph_size_and_title 

      select("count(arc_id) as size, media_resources.*, MD.title as meta_datum_title").
        joins("LEFT OUTER JOIN ( #{conditional_descendants_cte_query(scoped)} ) descendants ON media_resources.id = descendants.media_resource_id").
        # use a left outer join in the title true
        joins(" LEFT OUTER JOIN 
      (SELECT meta_data.media_resource_id as media_resource_id, meta_data.string as title
          FROM meta_data 
          INNER JOIN meta_keys ON meta_keys.id = meta_data.meta_key_id 
          WHERE meta_keys.label = 'title'
          ) MD ON  MD.media_resource_id = media_resources.id").
          group("media_resources.id, meta_datum_title") # note that yet alone id is unique
    end

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
end


