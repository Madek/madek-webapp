class InstitutionalGroup < Group

  has_and_belongs_to_many :meta_data,
                          join_table: :meta_data_institutional_groups,
                          association_foreign_key: :meta_datum_id,
                          foreign_key: :institutional_group_id

  default_scope { order(:name) }

  scope :by_string, lambda {|s|
    a = /(.*) \((.*)\)/.match(s)
    name, institutional_group_name = [a[1], a[2]]
    where(name: name, institutional_group_name: institutional_group_name)
  }

  # the scope :selectable is meant to be overwritten, i.e. monkey patched, on a
  # per instance basis, to provide filtered list when adding
  # InstitutionalGroups as metadata to a resource
  scope :selectable, -> {}

  # this is also to be overwritten!
  def to_s
    "#{name} (#{institutional_group_name})"
  end

  def to_limited_s(n = 80)
    n = n.to_i

    if to_s.mb_chars.size > n
      "#{to_s.mb_chars.limit(n)}..."
    else
      to_s
    end
  end

  def readonly?
    true
  end

end
