class SimplifyAndCleanMetaTerms < ActiveRecord::Migration

  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end

  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end


  class OldMetaTerm < ActiveRecord::Base
    has_many :meta_key_meta_terms, :foreign_key => :old_meta_term_id

    has_and_belongs_to_many :meta_data,
      join_table: :meta_data_old_meta_terms, 
      foreign_key: :old_meta_term_id, 
      association_foreign_key: :meta_datum_id
  end

  class MetaTerm < ActiveRecord::Base
     has_many :meta_key_meta_terms, :foreign_key => :meta_term_id

     has_and_belongs_to_many :meta_data,
       join_table: :meta_data_meta_terms, 
       foreign_key: :meta_term_id, 
       association_foreign_key: :meta_datum_id
  end

  class MetaKeyMetaTerm < ActiveRecord::Base
    self.table_name = 'meta_keys_meta_terms'

    belongs_to :meta_term
    belongs_to :old_meta_term
  end

  class XMetaDatumMetaTerms < ActiveRecord::Base
    self.table_name = 'meta_data'
    self.inheritance_column = :_type_disabled

    default_scope lambda{
      where(type: 'MetaDatumMetaTerms')
    }

    has_and_belongs_to_many :old_meta_terms, 
      join_table: :meta_data_old_meta_terms, 
      foreign_key: :meta_datum_id, 
      association_foreign_key: :old_meta_term_id

    has_and_belongs_to_many :meta_terms, 
      join_table: :meta_data_meta_terms, 
      foreign_key: :meta_datum_id, 
      association_foreign_key: :meta_term_id
  end




  def up

    rename_table :meta_terms, :old_meta_terms
    rename_column :meta_keys_meta_terms, :meta_term_id, :old_meta_term_id
    add_column :meta_keys_meta_terms, :meta_term_id, :uuid 

    rename_column :meta_data_meta_terms, :meta_term_id, :old_meta_term_id
    rename_table :meta_data_meta_terms, :meta_data_old_meta_terms

    create_table :meta_terms, id: false do |t|
      t.uuid :id, default: 'uuid_generate_v4()'
      t.text :term, default: "", null: false
      t.index :term, unique: true
    end
    execute 'ALTER TABLE meta_terms ADD PRIMARY KEY (id)'

    create_table :meta_data_meta_terms, id: false do |t|
      t.uuid :meta_datum_id, null: false
      t.uuid :meta_term_id, null: false
      t.index :meta_term_id
      t.index :meta_datum_id
    end
    add_foreign_key :meta_data_meta_terms, :meta_data, dependent: :delete
    add_foreign_key :meta_data_meta_terms, :meta_terms, dependent: :delete


    MetaKeyMetaTerm.all.each do |mkt|
      term= mkt.old_meta_term.de_ch
      mkt.update_attributes! meta_term: MetaTerm.find_or_create_by(term: term)
    end
    remove_column :meta_keys_meta_terms, :old_meta_term_id
    add_foreign_key :meta_keys_meta_terms , :meta_terms


    XMetaDatumMetaTerms.all.each do |mdmt|
      mdmt.old_meta_terms.each do |omt| 
        term= omt.de_ch
        mdmt.meta_terms << MetaTerm.find_or_create_by(term: term)
      end
      mdmt.save!
    end

    drop_table :meta_data_old_meta_terms
    drop_table :old_meta_terms

    create_trgm_index :meta_terms, :term
    create_text_index :meta_terms, :term

  end
end
