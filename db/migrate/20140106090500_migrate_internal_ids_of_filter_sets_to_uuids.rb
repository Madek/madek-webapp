class MigrateInternalIdsOfFilterSetsToUuids < ActiveRecord::Migration
  def up
    FilterSet.all.each do |filter_set|

      section = "meta_data"
      if data = filter_set.settings.try(:[],"filter").try(:[],section)
        data.each_pair do |k,v|
          case k
          when "keywords", "type"
            if ids = v["ids"]
              filter_set.settings["filter"][section][k]["ids"]= ids.map{ |id| 
                if id.to_i == 0 
                  id
                elsif mt = MetaTerm.find_by(previous_id: id) 
                  mt.id
                else
                  nil
                end
              }.reject(&:nil?)
            end
          when  "institutional affiliation"
            if ids = v["ids"]
              filter_set.settings["filter"][section][k]["ids"]= ids.map{ |id|
                if id.to_i == 0 
                  id
                elsif mt = MetaDepartement.find_by(previous_id: id) 
                  mt.id
                else
                  nil
                end
              }.reject(&:nil?)
            end
          else
            if meta_key = MetaKey.find_by(id: k)
              raise "not supported type" unless meta_key.meta_datum_object_type == "MetaDatumMetaTerms"
              if ids = v["ids"]
                filter_set.settings["filter"][section][k]["ids"]= ids.map{ |id|
                  if id.to_i == 0 
                    id
                  elsif mt = MetaTerm.find_by(previous_id: id) 
                    mt.id
                  else
                    nil
                  end
                }.reject(&:nil?)
              end
            end
          end
        end
      end
 
      section = "permissions"
      if data = filter_set.settings.try(:[],"filter").try(:[],section)
        data.each_pair do |k,v|
          case k
          when "owner"
            if ids = v["ids"]
              filter_set.settings["filter"][section][k]["ids"]= ids.map{ |id| 
                if id.to_i == 0 
                  id
                elsif d = User.find_by(previous_id: id) 
                  d.id
                else
                  nil
                end
              }.reject(&:nil?)
            end
          end
        end
      end

      filter_set.save!
    end
  end
end
