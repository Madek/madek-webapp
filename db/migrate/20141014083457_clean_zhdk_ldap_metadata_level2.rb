class CleanZhdkLdapMetadataLevel2 < ActiveRecord::Migration
  def change

    reversible do |dir|
      dir.up do

        MediaResource.find_in_batches do |mrs|
          mrs.each do |mr|
            begin 
              ig_removed= false
              if md= mr.meta_data.find_by(type: 'MetaDatumInstitutionalGroups')
                md_map = Hash[md.institutional_groups.where("institutional_group_name ~* '\.alle$' ") \
                              .map{|ig| [ig.institutional_group_name.gsub(/\.alle$/,"").split(/_/),ig]} \
                              .sort_by{|k,v| k.size * -1}]
                md_map.each do |k,ig|
                  sub= k.reverse.drop(1).reverse 
                  if (! sub.empty?) and md_map[sub] 
                    ig_removed= true
                    md.institutional_groups.delete ig
                    break
                  end
                end
              end
            end while ig_removed
          end
        end

      end
    end

  end
end
