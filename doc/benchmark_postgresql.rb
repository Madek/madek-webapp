# This is to benchmark PostgreSQL on simfs vs. NFS vs. ploop


class Benchmark

  def initialize(benchmarks = [])
  end

  def run
    benchmarks.each do |benchmark|
      Benchmark.ms do 
        # do shit here

      end

    end
  end

end


benchmarks = []

benchmarks << {
  :name => 'Loading one media resource while respecting its permissions',
  :query => "SELECT \"media_resources\".* FROM \"media_resources\" WHERE \"media_resources\".\"id\" = 5221 AND ( media_resources.user_id = 10262
    OR
    media_resources.view = true
    OR
    EXISTS ( SELECT 'true' FROM \"userpermissions\" WHERE \"userpermissions\".\"view\" = 't' AND \"userpermissions\".\"user_id\" = 10262 AND (userpermissions.media_resource_id = media_resources.id) )
    OR
    EXISTS ( SELECT 'true' FROM \"grouppermissions\" INNER JOIN \"groups\" ON \"groups\".\"id\" = \"grouppermissions\".\"group_id\" INNER JOIN \"groups_users\" ON \"groups_users\".\"group_id\" = \"groups\".\"id\" INNER JOIN \"users\" ON \"users\".\"id\" = \"groups_users\".\"user_id\" WHERE \"grouppermissions\".\"view\" = 't' AND (grouppermissions.media_resource_id = media_resources.id) AND (users.id = 10262) )
     ) LIMIT 1 "
}

benchmarks << {
  :name => 'Counting some stuff that a user probably can do, I guess',
  :query => "SELECT COUNT(*) FROM "media_resources" WHERE "media_resources"."id" = 61297 AND ( media_resources.user_id = 10262
   OR
    media_resources.edit = true
     OR
      EXISTS ( SELECT 'true' FROM "userpermissions" WHERE "userpermissions"."edit" = 't' AND "userpermissions"."user_id" = 10262 AND (userpermissions.media_resource_id = media_resources.id) )
       OR
        EXISTS ( SELECT 'true' FROM "grouppermissions" INNER JOIN "groups" ON "groups"."id" = "grouppermissions"."group_id" INNER JOIN "groups_users" ON "groups_users"."group_id" = "groups"."id" INNER JOIN "users" ON "users"."id" = "groups_users"."user_id" WHERE "grouppermissions"."edit" = 't' AND (grouppermissions.media_resource_id = media_resources.id) AND (users.id = 10262) )
        )"
}


benchmarks << {
  :name => 'Getting all meta key titles',
  :query => "SELECT "meta_keys".* FROM "meta_keys" WHERE "meta_keys"."id" = 'title' LIMIT 1"
}


benchmarks << {
  :name => 'Some counting with a subquery and filter sets and shit',
  :query => "SELECT COUNT(count_column) FROM (SELECT 1 AS count_column FROM \"media_resources\" WHERE \"media_resources\".\"type\" IN ('MediaEntry', 'MediaSet', 'FilterSet') AND ( media_resources.user_id = 10262
   OR
    media_resources.view = true
     OR
      EXISTS ( SELECT 'true' FROM \"userpermissions\" WHERE \"userpermissions\".\"view\" = 't' AND \"userpermissions\".\"user_id\" = 10262 AND (userpermissions.media_resource_id = media_resources.id) )
       OR
        EXISTS ( SELECT 'true' FROM \"grouppermissions\" INNER JOIN \"groups\" ON \"groups\".\"id\" = \"grouppermissions\".\"group_id\" INNER JOIN \"groups_users\" ON \"groups_users\".\"group_id\" = \"groups\".\"id\" INNER JOIN \"users\" ON \"users\".\"id\" = \"groups_users\".\"user_id\" WHERE \"grouppermissions\".\"view\" = 't' AND (grouppermissions.media_resource_id = media_resources.id) AND (users.id = 10262) )
        ) AND (media_resources.user_id <> 10262) AND ( EXISTS ( SELECT 'true' FROM \"userpermissions\" WHERE \"userpermissions\".\"view\" = 't' AND \"userpermissions\".\"user_id\" = 10262 AND (userpermissions.media_resource_id = media_resources.id) )
         OR
          EXISTS ( SELECT 'true' FROM \"grouppermissions\" INNER JOIN \"groups\" ON \"groups\".\"id\" = \"grouppermissions\".\"group_id\" INNER JOIN \"groups_users\" ON \"groups_users\".\"group_id\" = \"groups\".\"id\" INNER JOIN \"users\" ON \"users\".\"id\" = \"groups_users\".\"user_id\" WHERE \"grouppermissions\".\"view\" = 't' AND (grouppermissions.media_resource_id = media_resources.id) AND (users.id = 10262) )
          ) LIMIT 11) subquery_for_count"
}
