class Media::Project < Media::Set

  has_and_belongs_to_many :individual_contexts, :class_name => "MetaContext",
                                                :join_table => :media_projects_meta_contexts,
                                                :foreign_key => :media_project_id


  # TODO this is used to construct url_path and partials, find a better solution!!! (route alias, ...)
  def self.model_name
    superclass.model_name
  end

  # TODO scope accessible media_entries only
  def abstract(min_media_entries = nil, current_user = nil)
    min_media_entries ||= media_entries.count.to_f * 50 / 100
    accessible_media_entry_ids = if current_user
      MediaResource.accessible_by_user(current_user).media_entries.by_media_set(self).map(&:id)
    else
      media_entry_ids
    end
    meta_key_ids = individual_contexts.map(&:meta_key_ids).flatten
    h = {} #1005# TODO upgrade to Ruby 1.9 and use ActiveSupport::OrderedHash.new
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
    mds.each do |md|
      h[md.meta_key_id] ||= [] # TODO md.meta_key
      h[md.meta_key_id] << md.value
    end
    h.delete_if {|k, v| v.size < min_media_entries }
    h.each_pair {|k, v| h[k] = v.flatten.group_by {|x| x}.delete_if {|k, v| v.size < min_media_entries }.keys }
    h.delete_if {|k, v| v.blank? }
    #1005# return h.collect {|k, v| meta_data.build(:meta_key_id => k, :value => v) }
    b = []
    h.each_pair {|k, v| b[meta_key_ids.index(k)] = meta_data.build(:meta_key_id => k, :value => v) }
    return b.compact
  end

  def used_meta_term_ids(current_user = nil)
    accessible_media_entry_ids = if current_user
      MediaResource.accessible_by_user(current_user).media_entries.by_media_set(self).map(&:id)
    else
      media_entry_ids
    end
    meta_key_ids = individual_contexts.map{|ic| ic.meta_keys.for_meta_terms.map(&:id) }.flatten
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :resource_type => "MediaEntry", :resource_id => accessible_media_entry_ids)
    mds.collect(&:value).flatten.uniq.compact
  end

###################################################

=begin
  # NOTE config.gem "rgl", :lib => "rgl/adjacency"
  # http://rgl.rubyforge.org/ - http://www.graphviz.org/
  # require 'rgl/adjacency'
  require 'rgl/dot'
  # TODO use ruby-graphviz gem instead ??
  def graph
    current_user = nil # TODO
    mes = MediaResource.accessible_by_user(current_user).media_entries.by_media_set(self)

    g = RGL::DOT::Digraph.new({ 'name' => title,
                                'label' => "#{title}\n#{DateTime.now.to_formatted_s(:date_time)}" })

    mes.each do |media_entry|
      g << RGL::DOT::Node.new({'name' => "#{media_entry.id}" })
    end 


#=begin
    individual_contexts.each do |context|
      sg_keys = RGL::DOT::Subgraph.new({ 'name' => "#{context}",
                                        'label' => "#{context}",
                                        'color' => '#A1D4F1'})

      context.meta_keys.for_meta_terms.each do |meta_key|
        sg_keys << RGL::DOT::Node.new({'name' => meta_key.label  })

        meta_key.meta_terms.each do |meta_term|
          sg_keys << RGL::DOT::Node.new({'name' => "#{meta_term}" })

          color = "#"
          3.times { c = rand(8); color << "#{c}"*2 }
          media_entries.each do |media_entry|
            sg_keys << RGL::DOT::Node.new({'name' => "#{media_entry.id}" })

            sg_keys << RGL::DOT::DirectedEdge.new({'from' => "#{meta_term}",
                                                    'to' => "#{media_entry.id}",
                                                    'arrowhead' => 'none',
                                                    'arrowtail' => 'none',
                                                    'headport' => 'w',
                                                    'tailport' => 'e',
                                                    'color' => color })
          end 
        end
      end
      
      g << sg_keys
    end
#=end
    
    fmt = 'svg' # 'png'
    dotfile = "app/assets/images/graphs/project_#{id}"
    src = dotfile + ".dot"
    dot = dotfile + "." + fmt

    File.open(src, 'w') do |f|
      f << g.to_s << "\n"
    end
    system( "/usr/local/bin/neato -T#{fmt} #{src} -o #{dot}" ) # dot # neato # twopi # circo # fdp # sfdp 
    dot.gsub('app/assets/images/', '/assets/')
  end
=end

end
