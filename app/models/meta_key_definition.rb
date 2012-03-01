# -*- encoding : utf-8 -*-
#= MetaKeyDefinition
#
# Our association object between a MetaContext and a MetaKey, with a serialized value.
#
# A meta key definition provides a description and label for a particular meta-key in a particular context.

class MetaKeyDefinition < ActiveRecord::Base

  belongs_to    :meta_context
  belongs_to    :meta_key

  validates_presence_of :meta_key 
  validate do |record|
    if record.meta_context.is_user_interface?
      record.errors.add(:base, "key_map has to be blank") unless record.key_map.blank? 
    else
      record.errors.add(:base, "key_map can't be blank") if record.key_map.blank?
    end
  end

#########################

  [:label, :description, :hint].each do |name|
    belongs_to name, :class_name => "MetaTerm"
    define_method "#{name}=" do |h|
      write_attribute("#{name}_id", MetaTerm.find_or_create(h).try(:id))
    end
  end

  # TODO Rails 3.2
  # store :settings, accessors: [:is_required, :length_min, :length_max]
  serialize :settings, Hash
  [:is_required, :length_min, :length_max].each do |name|
    define_method name do
      self.settings[name]
    end
    define_method "#{name}=" do |i|
      self.settings[name] = i
    end
  end

###################################################

  # NOTE config.gem "rgl", :lib => "rgl/adjacency"
  # http://rgl.rubyforge.org/ - http://www.graphviz.org/
  # require 'rgl/adjacency'
  require 'rgl/dot'
  # TODO use ruby-graphviz gem instead ??
  def self.keymapping_graph
      g = RGL::DOT::Digraph.new({ 'name' => 'MAdeK keymapping',
                                  'style' => "filled",
                                  'nodesep' => ".075",
                                  'label' => "Key Mapping Graph\n#{DateTime.now.to_formatted_s(:date_time)}",
                                  'labelloc' => 't',
                                  'labeljust' => 'l',
                                  'ranksep' => "4.0",
                                  'rankdir' => "LR" })
                                #  node [shape=box,width=.1,height=.1]

      ####### Internal cluster
      sg_keys = RGL::DOT::Subgraph.new({ 'name' => "cluster_internal",
                                    'label' => "Internal",
                                    'color' => '#A1D4F1'})

        MetaKey.all.each do |meta_key|
          sg_keys << RGL::DOT::Node.new({'name' => meta_key.label,
                                          'shape' => "box",
                                          'style' => meta_key.is_dynamic? ? "filled" : "",
                                          'width' => "2.7", 'height' => "0" })
        end
  
        ####### for_interface
        MetaContext.for_interface.each do |context|
          sg = RGL::DOT::Node.new({'name' => context,
                                    'shape' => "box",
                                    'style' => "filled",
                                    'width' => "1.5", 'height' => "1.5" })
          sg_keys << sg
          color = "#"
          3.times { c = rand(8); color << "#{c}"*2 }
          context.meta_key_definitions.all.each do |definition|
            sg_keys << RGL::DOT::DirectedEdge.new({'from' => definition.meta_key.label,
                                                    'to' => context,
                                                    'arrowhead' => 'none',
                                                    'arrowtail' => 'none',
                                                    'headport' => 'w',
                                                    'tailport' => 'e',
                                                    'color' => color })
          end
        end
      g << sg_keys
      

      ####### External cluster
      sg_keys = RGL::DOT::Subgraph.new({ 'name' => "cluster_external",
                                    'label' => "External",
                                    'color' => '#A1D4F1'})

#working here#10      
#        all(:select => :key_map, :group => :key_map, :conditions => "key_map IS NOT NULL").each do |definition|
#          sg_keys << RGL::DOT::Node.new({ 'name' => definition.key_map, # TODO split(',')
#                                          'shape' => "box",
#                                          'width' => "0", 'height' => "0" })
#        end
  
        colors = {}
        ####### for_import_export
        MetaContext.for_import_export.each do |context|
          sg = RGL::DOT::Node.new({ 'name' => context,
                                    'shape' => "box",
                                    'style' => "filled",
                                    'width' => "1.5", 'height' => "1.5" })
          sg_keys << sg

          color = "#"
          3.times { c = rand(8); color << "#{c}"*2 }
          colors[context] = color

#working here#10
#          context.meta_key_definitions.each do |definition|
#            sg_keys << RGL::DOT::DirectedEdge.new({'from' => context,
#                                                    'to' => definition.key_map, # TODO split(',')
#                                                    'dir' => 'back',
#                                                    'color' => color })
#            sg_keys << RGL::DOT::DirectedEdge.new({'from' => definition.key_map, # TODO split(',')
#                                                  'to' => definition.meta_key.label,
#                                                  'dir' => 'back',
#                                                  'color' => color })
#          end
        end

        disinct_key_map =
          if SQLHelper.adapter_is_postgresql? 
            select " DISTINCT ON (key_map) * " 
          elsif SQLHelper.adapter_is_mysql?
            group :key_map 
          end

        disinct_key_map.where("key_map IS NOT NULL").each do |definition|
          definition.key_map.split(',').collect do |km|
            km.strip!

            sg_keys << RGL::DOT::Node.new({ 'name' => km,
                                            'shape' => "box",
                                            'width' => "3.6", 'height' => "0" })
  
            sg_keys << RGL::DOT::DirectedEdge.new({'from' => definition.meta_context, #working here#10 crashes if many meta_key_definitions are found!!!
                                                    'to' => km,
                                                    'arrowhead' => 'none',
                                                    'arrowtail' => 'none',
                                                    'headport' => 'w',
                                                    'tailport' => 'e',
                                                    #'dir' => 'back',
                                                    'color' => colors[definition.meta_context] })
            sg_keys << RGL::DOT::DirectedEdge.new({'from' => km,
                                                  'to' => MetaKey.meta_key_for(km).label,
                                                  'arrowhead' => 'none',
                                                  'arrowtail' => 'none',
                                                  'headport' => 'w',
                                                  'tailport' => 'e',
                                                  #'dir' => 'back',
                                                  'color' => colors[definition.meta_context] })
          end
        end
      g << sg_keys


      fmt = 'svg' # 'png'
      dotfile = "app/assets/images/graphs/meta"
      src = dotfile + ".dot"
      dot = dotfile + "." + fmt

      File.open(src, 'w') do |f|
        f << g.to_s << "\n"
      end
      system( "#{DOT_PATH} -T#{fmt} #{src} -o #{dot}" ) # dot # neato # twopi # circo # fdp # sfdp 
      dot.gsub('app/assets/images/', '/assets/')

    ############ end graph
  end

end
