# -*- encoding : utf-8 -*-
require "metahelper"

class Admin::MetaController < Admin::AdminController

  def import
    @buffer = []
    if request.post? and params[:uploaded_data]
      @buffer = MetaHelper.import_initial_metadata params[:uploaded_data]
    end
  end

  def export
      h = {}

      h[:meta_terms] = MetaTerm.all.collect(&:attributes)

      h[:meta_keys] = MetaKey.all.collect do |meta_key|
        a = meta_key.attributes
        a["meta_terms"] = meta_key.meta_terms.collect(&:id) if meta_key.object_type == "MetaTerm"
        a
      end

      h[:meta_contexts] = MetaContext.all.collect do |meta_contexts|
        a = {}
        ["id", "name", "is_user_interface"].each do |b|
          v = meta_contexts.send(b)
          a[b] = v unless v.blank?
        end
        a["meta_field"] = meta_contexts.meta_field.instance_values
        a
      end

      h[:meta_key_definitions] = MetaKeyDefinition.all.collect do |meta_key_definition|
        a = {}
        ["id", "meta_key_id", "meta_context_id", "position", "key_map", "key_map_type"].each do |b|
          v = meta_key_definition.send(b)
          a[b] = v unless v.blank?
        end
        a["meta_field"] = meta_key_definition.meta_field.instance_values
        a
      end

#future#
#      h[:copyrights] = Copyright.all.collect(&:attributes)

      h[:usage_terms] = UsageTerm.current.attributes

      send_data h.to_yaml, :filename => "meta.yml", :type => :yaml
  end

end
