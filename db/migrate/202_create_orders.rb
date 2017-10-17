class CreateOrders < ActiveRecord::Migration[5.0]
  def up
    add_column :orders, :purpose_id, :uuid

    ##########################################################################
    ### submitted and rejected reservations
    ##########################################################################

    ['submitted', 'rejected'].each do |state|
      ### reservations with purpose_id ###
      execute <<-SQL
        INSERT INTO orders (user_id, inventory_pool_id, purpose, purpose_id, state, created_at, updated_at)
        SELECT reservations.user_id,
               reservations.inventory_pool_id,
               CASE
                   WHEN purposes.description ~ '^\\s*$'
                        OR purposes.description IS NULL THEN 'unknown purpose'
                   ELSE purposes.description
               END AS purpose,
               reservations.purpose_id,
               '#{state}' AS state,
               MAX(reservations.created_at),
               MAX(reservations.updated_at)
        FROM reservations
        INNER JOIN purposes on reservations.purpose_id = purposes.id
        WHERE reservations.status = '#{state}'
          AND type = 'ItemLine'
        GROUP BY reservations.user_id,
                 reservations.inventory_pool_id,
                 reservations.purpose_id,
                 purposes.description;
      SQL

      execute <<-SQL
        UPDATE reservations
        SET order_id = orders.id
        FROM orders
        WHERE reservations.purpose_id = orders.purpose_id
          AND reservations.user_id = orders.user_id
          AND reservations.inventory_pool_id = orders.inventory_pool_id
          AND reservations.type = 'ItemLine'
          AND reservations.status = '#{state}'
      SQL

      ### reservations without purpose_id ###

      execute <<-SQL
        UPDATE reservations
        SET order_id = grouped_reservations.order_id
        FROM
          ( SELECT reservations.user_id,
                   reservations.inventory_pool_id,
                   uuid_generate_v4() AS order_id
           FROM reservations
           WHERE reservations.status = '#{state}'
             AND type = 'ItemLine'
             AND reservations.purpose_id is null
           GROUP BY reservations.user_id,
                    reservations.inventory_pool_id ) AS grouped_reservations
        WHERE reservations.user_id = grouped_reservations.user_id
          AND reservations.inventory_pool_id = grouped_reservations.inventory_pool_id
          AND reservations.status = '#{state}'
      SQL

      execute <<-SQL
        INSERT INTO orders (id, user_id, inventory_pool_id, purpose, state, created_at, updated_at)
        SELECT reservations.order_id,
               reservations.user_id,
               reservations.inventory_pool_id,
               'unknown purpose' AS purpose,
               '#{state}' AS state,
               MAX(reservations.created_at),
               MAX(reservations.updated_at)
        FROM reservations
        WHERE reservations.status = '#{state}'
          AND type = 'ItemLine'
          AND reservations.purpose_id is null
        GROUP BY reservations.order_id,
                 reservations.user_id,
                 reservations.inventory_pool_id
      SQL
    end

    ##########################################################################
    ### approved, signed and closed reservations
    ##########################################################################

    execute <<-SQL
      INSERT INTO orders (user_id, inventory_pool_id, purpose, purpose_id, state, created_at, updated_at)
      SELECT reservations.user_id,
             reservations.inventory_pool_id,
             CASE
                 WHEN purposes.description ~ '^\\s*$'
                      OR purposes.description IS NULL THEN 'unknown purpose'
                 ELSE purposes.description
             END AS purpose,
             reservations.purpose_id,
             'approved' AS state,
             MAX(reservations.created_at),
             MAX(reservations.updated_at)
      FROM reservations
      INNER JOIN purposes on reservations.purpose_id = purposes.id
      WHERE reservations.status IN ('approved', 'signed', 'closed')
        AND type = 'ItemLine'
      GROUP BY reservations.user_id,
               reservations.inventory_pool_id,
               reservations.purpose_id,
               purposes.description;
    SQL

    execute <<-SQL
      UPDATE reservations
      SET order_id = orders.id
      FROM orders
      WHERE reservations.purpose_id = orders.purpose_id
        AND reservations.user_id = orders.user_id
        AND reservations.inventory_pool_id = orders.inventory_pool_id
        AND reservations.type = 'ItemLine'
        AND reservations.status IN ('approved', 'signed', 'closed')
        AND NOT EXISTS (
          SELECT 1
          FROM orders
          WHERE orders.purpose_id = reservations.purpose_id
            AND orders.state IN ('submitted', 'rejected'))
    SQL

    ### reservations without purpose_id ###
    ### are ignored as they might have been added to the hand over by the lending manager ###
  end

  def down
    execute 'DELETE FROM orders'
    remove_column :orders, :purpose_id
  end
end
