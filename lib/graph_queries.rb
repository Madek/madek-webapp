require 'set'

module GraphQueries

  def self.reachable_arcs_query media_set
    "
      WITH RECURSIVE pair(p,c) as
      (
          SELECT parent_id as p, child_id as c FROM media_resource_arcs 
            WHERE parent_id = #{media_set.id}
        UNION
          SELECT parent_id as p, child_id as c FROM pair, media_resource_arcs
            WHERE parent_id = pair.c
      ) 
      SELECT id FROM media_resource_arcs, pair
        WHERE media_resource_arcs.parent_id = pair.p
        AND media_resource_arcs.child_id = pair.c
    "
  end

  def self.reachable_arcs media_set
    if SQLHelper.adapter_is_postgresql? 
      MediaResourceArc.where(" id in ( #{reachable_arcs_query(media_set)} )")
    else 
      arc_ids = Set.new(MediaResourceArc.where("parent_id = ?",media_set.id).map(&:id))
      begin
        arcs = MediaResourceArc.where("id in ( ? )",arc_ids)
        prev_arc_ids = arc_ids
        arc_ids = arc_ids | MediaResourceArc.where("parent_id in ( ? ) ", arcs.map(&:child_id))
      end while prev_arc_ids != arc_ids
      MediaResourceArc.where("id in ( ? )", arc_ids)
    end
  end

  def self.descendants media_set
    MediaResource.where(" id in ( #{reachable_arcs(media_set).select("child_id").to_sql} ) ")
  end
 
end

