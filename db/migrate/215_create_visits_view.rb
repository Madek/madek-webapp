class CreateVisitsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW visits AS
      SELECT UUID_GENERATE_V5 (
               UUID_NS_DNS(),
               CONCAT_WS ('_', visit_reservations.user_id, visit_reservations.inventory_pool_id, visit_reservations.status, visit_reservations.date)
              ) AS id,
             visit_reservations.user_id,
             visit_reservations.inventory_pool_id,
             visit_reservations.date,
             visit_reservations.visit_type AS type,
             CASE
               WHEN visit_reservations.status = 'submitted' THEN FALSE
               WHEN visit_reservations.status IN ('approved', 'signed') THEN TRUE
             END AS is_approved,
             SUM ( visit_reservations.quantity ) AS quantity,
             BOOL_OR ( visit_reservations.with_user_to_verify ) AS with_user_to_verify,
             BOOL_OR ( visit_reservations.with_user_and_model_to_verify ) AS with_user_and_model_to_verify,
             ARRAY_AGG ( visit_reservations.id ) AS reservation_ids
      FROM
        (SELECT reservations.id,
                reservations.user_id,
                reservations.inventory_pool_id,
                CASE
                    WHEN reservations.status IN ('submitted', 'approved') THEN reservations.start_date
                    WHEN reservations.status = 'signed' THEN reservations.end_date
                END AS date,
                CASE
                  WHEN reservations.status IN ('submitted', 'approved') THEN 'hand_over'
                  WHEN reservations.status = 'signed' THEN 'take_back'
                END AS visit_type,
                reservations.status,
                reservations.quantity,
                EXISTS (
                  SELECT 1
                  FROM entitlement_groups_users
                  JOIN entitlement_groups on entitlement_groups.id = entitlement_groups_users.entitlement_group_id
                  WHERE entitlement_groups_users.user_id = reservations.user_id
                    AND entitlement_groups.is_verification_required IS TRUE
                ) AS with_user_to_verify,
                EXISTS (
                  SELECT 1
                  FROM entitlements
                  JOIN entitlement_groups on entitlement_groups.id = entitlements.entitlement_group_id
                  JOIN entitlement_groups_users on entitlement_groups_users.entitlement_group_id = entitlement_groups.id
                  WHERE entitlements.model_id = reservations.model_id
                    AND entitlement_groups_users.user_id = reservations.user_id
                    AND entitlement_groups.is_verification_required IS TRUE
                ) AS with_user_and_model_to_verify
         FROM reservations
         WHERE reservations.status IN ('submitted',
                                       'approved',
                                       'signed')) AS visit_reservations
      GROUP BY visit_reservations.user_id,
               visit_reservations.inventory_pool_id,
               visit_reservations.date,
               visit_reservations.visit_type,
               visit_reservations.status
    SQL
  end

  def down
    execute 'DROP VIEW visits'
  end
end
