class Dilps::Base < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "dilps"


  class << self

    def create_views
      create_collection_view
      create_connection_view
      create_ext_data_view
      create_nested_groups_view
      create_resource_revs_view
      create_super_items_view
    end


    def create_collection_view 
      connection.execute <<-SQL

      CREATE OR REPLACE 
        SQL SECURITY INVOKER
        VIEW collections AS 

        SELECT
          d2_collection.collectionid AS id,
          d2_collection.*
        FROM
          d2_collection

      SQL
    end


    def create_ext_data_view
      connection.execute <<-SQL

      CREATE OR REPLACE 
        SQL SECURITY INVOKER
        VIEW extended_data AS 

        SELECT REPLACE(d2_item_ext_data.name,'::','_') AS ltype, d2_item_ext_data.*
        FROM d2_item_ext_data

      SQL
    end


    def create_connection_view
      connection.execute <<-SQL
        CREATE OR REPLACE 
          SQL SECURITY INVOKER
          VIEW connections AS 

            SELECT 
              item_collection AS collection_id,
              groupid AS group_id,
              itemid AS item_id,
              resourceid AS resource_id
            FROM d2_group_resource
      SQL
    end


    def create_resource_revs_view
      connection.execute <<-SQL
      CREATE OR REPLACE 
        SQL SECURITY INVOKER
        VIEW resource_revs AS 

        SELECT * FROM d2_resource_rev
      SQL
    end

    def create_super_items_view
      connection.execute <<-SQL

      CREATE OR REPLACE 
        SQL SECURITY INVOKER
        VIEW super_items AS 

        SELECT group_resource_items.item_collection AS collection_id, 
          group_resource_items.resourceid AS resource_id, 
          group_resource_items.itemid AS item_id, 
          item_revs.id AS item_rev_id, 
          item_revs.addition, 
          item_revs.dating, 
          item_revs.dating_from, 
          item_revs.format AS dilps_format, 
          item_revs.institution,
          item_revs.dating_to, 
          item_revs.country, 
          item_revs.location, 
          item_revs.keyword,
          item_revs.name1, 
          item_revs.name2,
          item_revs.source,
          item_revs.title
        FROM d2_item_rev item_revs, d2_group_resource group_resource_items
        WHERE TRUE
        AND item_revs.itemid = group_resource_items.itemid
        AND item_revs.collectionid = group_resource_items.item_collection
        AND item_revs.id = (
          SELECT
            max(item_rev_inner.id)
          FROM
            d2_item_rev AS item_rev_inner,
            d2_group_resource AS group_resource_inner
          WHERE
            TRUE
          AND item_rev_inner.collectionid = group_resource_inner.item_collection
          AND item_rev_inner.itemid = group_resource_inner.itemid -- connect to outer
          AND group_resource_inner.itemid = group_resource_items.itemid
          AND group_resource_inner.item_collection = group_resource_items.item_collection
        )

      SQL
    end

    def create_to_be_deleted_rev_items_view
      # the plan was to use this to delete rev_items we  don't need,
      # it doesn't work since it is not allowed to access a table while deleting from it
      self.connection.execute <<-SQL
      CREATE OR REPLACE 
        SQL SECURITY INVOKER
        VIEW to_be_deleted_item_revs AS 
      SELECT id
      FROM
        d2_item_rev AS item_rev
      WHERE id <> (
        SELECT
          max(id)
        FROM
          d2_item_rev AS max_item_rev
        WHERE
          max_item_rev.itemid = item_rev.itemid )
      SQL

    end

    def create_nested_groups_view
      self.connection.execute <<-SQL
      CREATE OR REPLACE 
        SQL SECURITY INVOKER
        VIEW nested_groups AS 
          SELECT 
            l1_group.id AS l1_id, 
            l1_group.name AS l1_name, 
            l2_group.id as l2_id, 
            l2_group.name AS l2_name, 
            l3_group.id as l3_id ,  
            l3_group.name AS l3_name
          FROM 
            d2_group AS l1_group, 
            d2_group AS l2_group, 
            d2_group AS l3_group
          WHERE true
          AND l1_group.id = l2_group.parent
          AND l2_group.id = l3_group.parent
      SQL
    end

  end

end
