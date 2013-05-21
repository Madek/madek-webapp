MediaResource.find(54288).individual_contexts << MetaContext.find(39)

MetaKey.create! id: "VID_OneMillion", is_extensible_list: false, meta_datum_object_type: "MetaDatumMetaTerms"
MetaKeyDefinition.create! meta_key_id: "VID_OneMillion",position: 2, meta_context_id: 39 , label: MetaTerm.create!(de_ch: "1-Million-Dollar-Shot")

MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Studioaufnahme")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Kontextaufnahme")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "CAD-Rendering")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Handrendering")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.find(621)
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Prozessbild")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Austellungsfotografie")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Veranstaltungsfotografie")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Andere")
MetaKeyMetaTerm.create! meta_key_id: "VID_OneMillion", meta_term: MetaTerm.create!(de_ch: "Presse")


MetaKey.create! id: "VID_Schwerpunkt", is_extensible_list: false, meta_datum_object_type: "MetaDatumMetaTerms"
MetaKeyDefinition.create! meta_key_id: "VID_Schwerpunkt", position: 1, meta_context_id: 39 , label: MetaTerm.create!(de_ch: "Schwerpunkt")

MetaKeyMetaTerm.create! meta_key_id: "VID_Schwerpunkt", meta_term: MetaTerm.find(7285)
MetaKeyMetaTerm.create! meta_key_id: "VID_Schwerpunkt", meta_term: MetaTerm.find(4967)
MetaKeyMetaTerm.create! meta_key_id: "VID_Schwerpunkt", meta_term: MetaTerm.find(7337)

