# -*- encoding : utf-8 -*-
class Copyright < ActiveRecord::Base

  acts_as_nested_set
  
  validates_presence_of :label

  def to_s
    label
  end

  def usage(value = "")
    (is_custom? ? value : read_attribute(:usage))
  end

  def url(value = "")
    (is_custom? ? value : read_attribute(:url))
  end

#######################################
  
  def self.default
    @default ||= where(:is_default => true).first
  end

  def self.custom
    @custom ||= where(:is_custom => true).first
  end

  # OPTIMIZE
  def self.public
    @public ||= where(:label => "Public Domain (gemeinfrei)").first
  end

#######################################

  def self.init(reset = false)
    return 0 unless reset or count == 0
    delete_all

    file = "#{Rails.root}/config/definitions/helpers/copyrights.yml"
    entries = YAML.load(File.read(file))

    save_as_nested_set(entries)

    return count
  end

##################################################
  class << self

    def save_as_nested_set(nodes, parent = nil)
      case nodes.class.name
        when "Hash"
            if nodes.keys.first.is_a?(Hash)
              nodes.each_pair do |key,value|
                new_parent = create(key)
                new_parent.move_to_child_of parent if parent
                save_as_nested_set(value, new_parent) if value.is_a?(Array)
              end
            else
                new_leaf = create(nodes)
                new_leaf.move_to_child_of parent if parent
            end
        when "Array"
          nodes.each do |value|
            save_as_nested_set(value, parent)
          end
      end
    end

  end

end
