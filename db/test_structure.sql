CREATE TABLE `copyrights` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_default` tinyint(1) DEFAULT '0',
  `is_custom` tinyint(1) DEFAULT '0',
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  `usage` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_copyrights_on_label` (`label`),
  KEY `index_copyrights_on_is_default` (`is_default`),
  KEY `index_copyrights_on_is_custom` (`is_custom`),
  KEY `index_copyrights_on_parent_id` (`parent_id`),
  KEY `index_copyrights_on_lft_and_rgt` (`lft`,`rgt`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `edit_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `media_resource_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_on_resource_and_created_at` (`created_at`),
  KEY `index_edit_sessions_on_user_id` (`user_id`),
  KEY `index_edit_sessions_on_media_resource_id` (`media_resource_id`),
  CONSTRAINT `edit_sessions_media_resource_id_media_resources_fkey` FOREIGN KEY (`media_resource_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `favorites` (
  `user_id` int(11) DEFAULT NULL,
  `media_resource_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_favorites_on_user_id_and_media_resource_id` (`user_id`,`media_resource_id`),
  KEY `favorites_media_resource_id_media_resources_fkey` (`media_resource_id`),
  CONSTRAINT `favorites_media_resource_id_media_resources_fkey` FOREIGN KEY (`media_resource_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `full_texts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text COLLATE utf8_unicode_ci,
  `media_resource_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_full_texts_on_media_resource_id` (`media_resource_id`),
  CONSTRAINT `full_texts_media_resource_id_media_resources_fkey` FOREIGN KEY (`media_resource_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `grouppermissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_resource_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `download` tinyint(1) NOT NULL DEFAULT '0',
  `view` tinyint(1) NOT NULL DEFAULT '0',
  `edit` tinyint(1) NOT NULL DEFAULT '0',
  `manage` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_grouppermissions_on_group_id_and_media_resource_id` (`group_id`,`media_resource_id`),
  KEY `index_grouppermissions_on_group_id` (`group_id`),
  KEY `index_grouppermissions_on_media_resource_id` (`media_resource_id`),
  CONSTRAINT `grouppermissions_media_resource_id_media_resources_fkey` FOREIGN KEY (`media_resource_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE,
  CONSTRAINT `grouppermissions_group_id_groups_fkey` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ldap_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ldap_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Group',
  PRIMARY KEY (`id`),
  KEY `index_groups_on_ldap_id` (`ldap_id`),
  KEY `index_groups_on_ldap_name` (`ldap_name`),
  KEY `index_groups_on_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `groups_users` (
  `group_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_groups_users_on_group_id_and_user_id` (`group_id`,`user_id`),
  KEY `index_groups_users_on_user_id` (`user_id`),
  CONSTRAINT `groups_users_user_id_users_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `groups_users_group_id_groups_fkey` FOREIGN KEY (`group_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_term_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `meta_datum_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_keywords_on_term_id_and_user_id` (`meta_term_id`,`user_id`),
  KEY `index_keywords_on_user_id` (`user_id`),
  KEY `index_keywords_on_created_at` (`created_at`),
  KEY `index_keywords_on_meta_datum_id` (`meta_datum_id`),
  CONSTRAINT `keywords_meta_datum_id_meta_data_fkey` FOREIGN KEY (`meta_datum_id`) REFERENCES `meta_data` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `media_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `meta_data` text COLLATE utf8_unicode_ci,
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `job_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `access_hash` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `media_resource_arcs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `highlight` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_media_set_arcs_on_parent_id_and_child_id` (`parent_id`,`child_id`),
  KEY `index_media_set_arcs_on_parent_id` (`parent_id`),
  KEY `index_media_set_arcs_on_child_id` (`child_id`),
  CONSTRAINT `media_set_arcs_child_id_media_resources_fkey` FOREIGN KEY (`child_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE,
  CONSTRAINT `media_set_arcs_parent_id_media_resources_fkey` FOREIGN KEY (`parent_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `media_resources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `media_file_id` int(11) DEFAULT NULL,
  `media_entry_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `download` tinyint(1) NOT NULL DEFAULT '0',
  `view` tinyint(1) NOT NULL DEFAULT '0',
  `edit` tinyint(1) NOT NULL DEFAULT '0',
  `manage` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_media_resources_on_type` (`type`),
  KEY `index_media_resources_on_user_id` (`user_id`),
  KEY `index_media_resources_on_media_file_id` (`media_file_id`),
  KEY `index_media_resources_on_updated_at` (`updated_at`),
  KEY `index_media_resources_on_media_entry_id_and_created_at` (`media_entry_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `media_sets_meta_contexts` (
  `media_set_id` int(11) DEFAULT NULL,
  `meta_context_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_on_projects_and_contexts` (`media_set_id`,`meta_context_id`),
  CONSTRAINT `media_sets_meta_contexts_media_set_id_media_resources_fkey` FOREIGN KEY (`media_set_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_context_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_meta_context_groups_on_name` (`name`),
  KEY `index_meta_context_groups_on_position` (`position`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_contexts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_user_interface` tinyint(1) DEFAULT '0',
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `label_id` int(11) NOT NULL,
  `description_id` int(11) DEFAULT NULL,
  `meta_context_group_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_meta_contexts_on_name` (`name`),
  KEY `meta_contexts_label_id_meta_terms_fkey` (`label_id`),
  KEY `meta_contexts_description_id_meta_terms_fkey` (`description_id`),
  KEY `meta_contexts_meta_context_group_id_meta_context_groups_fkey` (`meta_context_group_id`),
  KEY `index_meta_contexts_on_position` (`position`),
  CONSTRAINT `meta_contexts_description_id_meta_terms_fkey` FOREIGN KEY (`description_id`) REFERENCES `meta_terms` (`id`),
  CONSTRAINT `meta_contexts_label_id_meta_terms_fkey` FOREIGN KEY (`label_id`) REFERENCES `meta_terms` (`id`),
  CONSTRAINT `meta_contexts_meta_context_group_id_meta_context_groups_fkey` FOREIGN KEY (`meta_context_group_id`) REFERENCES `meta_context_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_key_id` int(11) DEFAULT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `media_resource_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `string` text COLLATE utf8_unicode_ci,
  `copyright_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_meta_data_on_meta_key_id` (`meta_key_id`),
  KEY `index_meta_data_on_media_resource_id_and_meta_key_id` (`media_resource_id`,`meta_key_id`),
  KEY `index_meta_data_on_copyright_id` (`copyright_id`),
  CONSTRAINT `meta_data_copyright_id_copyrights_fkey` FOREIGN KEY (`copyright_id`) REFERENCES `copyrights` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meta_data_media_resource_id_media_resources_fkey` FOREIGN KEY (`media_resource_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_data_meta_departments` (
  `meta_datum_id` int(11) DEFAULT NULL,
  `meta_department_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_meta_data_meta_departments_datum_group` (`meta_datum_id`,`meta_department_id`),
  KEY `meta_data_meta_departments_meta_department_id_groups_fkey` (`meta_department_id`),
  CONSTRAINT `meta_data_meta_departments_meta_department_id_groups_fkey` FOREIGN KEY (`meta_department_id`) REFERENCES `groups` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meta_data_meta_departments_meta_datum_id_meta_data_fkey` FOREIGN KEY (`meta_datum_id`) REFERENCES `meta_data` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_data_meta_terms` (
  `meta_datum_id` int(11) DEFAULT NULL,
  `meta_term_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id` (`meta_datum_id`,`meta_term_id`),
  KEY `meta_data_meta_terms_meta_term_id_meta_terms_fkey` (`meta_term_id`),
  CONSTRAINT `meta_data_meta_terms_meta_term_id_meta_terms_fkey` FOREIGN KEY (`meta_term_id`) REFERENCES `meta_terms` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meta_data_meta_terms_meta_datum_id_meta_data_fkey` FOREIGN KEY (`meta_datum_id`) REFERENCES `meta_data` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_data_people` (
  `meta_datum_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_meta_data_people_on_meta_datum_id_and_person_id` (`meta_datum_id`,`person_id`),
  KEY `meta_data_people_person_id_people_fkey` (`person_id`),
  CONSTRAINT `meta_data_people_person_id_people_fkey` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meta_data_people_meta_datum_id_meta_data_fkey` FOREIGN KEY (`meta_datum_id`) REFERENCES `meta_data` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_data_users` (
  `meta_datum_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  UNIQUE KEY `index_meta_data_users_on_meta_datum_id_and_user_id` (`meta_datum_id`,`user_id`),
  KEY `meta_data_users_user_id_users_fkey` (`user_id`),
  CONSTRAINT `meta_data_users_user_id_users_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meta_data_users_meta_datum_id_meta_data_fkey` FOREIGN KEY (`meta_datum_id`) REFERENCES `meta_data` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_key_definitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meta_context_id` int(11) DEFAULT NULL,
  `meta_key_id` int(11) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `key_map` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `key_map_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `label_id` int(11) DEFAULT NULL,
  `description_id` int(11) DEFAULT NULL,
  `hint_id` int(11) DEFAULT NULL,
  `settings` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_meta_key_definitions_on_meta_context_id_and_position` (`meta_context_id`,`position`),
  KEY `index_meta_key_definitions_on_meta_key_id` (`meta_key_id`),
  KEY `meta_key_definitions_label_id_meta_terms_fkey` (`label_id`),
  KEY `meta_key_definitions_description_id_meta_terms_fkey` (`description_id`),
  KEY `meta_key_definitions_hint_id_meta_terms_fkey` (`hint_id`),
  CONSTRAINT `meta_key_definitions_description_id_meta_terms_fkey` FOREIGN KEY (`description_id`) REFERENCES `meta_terms` (`id`),
  CONSTRAINT `meta_key_definitions_hint_id_meta_terms_fkey` FOREIGN KEY (`hint_id`) REFERENCES `meta_terms` (`id`),
  CONSTRAINT `meta_key_definitions_label_id_meta_terms_fkey` FOREIGN KEY (`label_id`) REFERENCES `meta_terms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=848 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_dynamic` tinyint(1) DEFAULT NULL,
  `is_extensible_list` tinyint(1) DEFAULT NULL,
  `meta_datum_object_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_meta_keys_on_label` (`label`)
) ENGINE=InnoDB AUTO_INCREMENT=660 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_keys_meta_terms` (
  `meta_key_id` int(11) DEFAULT NULL,
  `meta_term_id` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `position` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_meta_keys_terms_on_meta_key_id_and_term_id` (`meta_key_id`,`meta_term_id`),
  KEY `index_meta_keys_meta_terms_on_position` (`position`)
) ENGINE=InnoDB AUTO_INCREMENT=1084 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `meta_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `en_gb` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `de_ch` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_terms_on_en_GB_and_de_CH` (`en_gb`,`de_ch`)
) ENGINE=InnoDB AUTO_INCREMENT=4812 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pseudonym` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `deathdate` date DEFAULT NULL,
  `nationality` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `wiki_links` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_group` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_people_on_firstname` (`firstname`),
  KEY `index_people_on_lastname` (`lastname`),
  KEY `index_people_on_is_group` (`is_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `permission_presets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `download` tinyint(1) NOT NULL DEFAULT '0',
  `view` tinyint(1) NOT NULL DEFAULT '0',
  `edit` tinyint(1) NOT NULL DEFAULT '0',
  `manage` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_bools_unique` (`view`,`edit`,`download`,`manage`),
  UNIQUE KEY `idx_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `previews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_file_id` int(11) DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_previews_on_media_file_id` (`media_file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `var` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `value` text COLLATE utf8_unicode_ci,
  `target_id` int(11) DEFAULT NULL,
  `target_type` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_settings_on_target_type_and_target_id_and_var` (`target_type`,`target_id`,`var`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `usage_terms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `version` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `intro` text COLLATE utf8_unicode_ci,
  `body` text COLLATE utf8_unicode_ci,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `userpermissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `media_resource_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `download` tinyint(1) NOT NULL DEFAULT '0',
  `view` tinyint(1) NOT NULL DEFAULT '0',
  `edit` tinyint(1) NOT NULL DEFAULT '0',
  `manage` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_userpermissions_on_media_resource_id_and_user_id` (`media_resource_id`,`user_id`),
  KEY `index_userpermissions_on_media_resource_id` (`media_resource_id`),
  KEY `index_userpermissions_on_user_id` (`user_id`),
  CONSTRAINT `userpermissions_media_resource_id_media_resources_fkey` FOREIGN KEY (`media_resource_id`) REFERENCES `media_resources` (`id`) ON DELETE CASCADE,
  CONSTRAINT `userpermissions_user_id_users_fkey` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `login` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `usage_terms_accepted_at` datetime DEFAULT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_login` (`login`),
  KEY `index_users_on_person_id` (`person_id`),
  CONSTRAINT `person_id_fkey` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `wiki_page_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_id` int(11) NOT NULL,
  `updator_id` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `comment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_wiki_page_versions_on_page_id` (`page_id`),
  KEY `index_wiki_page_versions_on_updator_id` (`updator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `wiki_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `creator_id` int(11) DEFAULT NULL,
  `updator_id` int(11) DEFAULT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_wiki_pages_on_path` (`path`),
  KEY `index_wiki_pages_on_creator_id` (`creator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20090304091402');

INSERT INTO schema_migrations (version) VALUES ('20090304091431');

INSERT INTO schema_migrations (version) VALUES ('20090310150441');

INSERT INTO schema_migrations (version) VALUES ('20090504143011');

INSERT INTO schema_migrations (version) VALUES ('20090505114718');

INSERT INTO schema_migrations (version) VALUES ('20090505120000');

INSERT INTO schema_migrations (version) VALUES ('20090529140042');

INSERT INTO schema_migrations (version) VALUES ('20090826101541');

INSERT INTO schema_migrations (version) VALUES ('20090827124700');

INSERT INTO schema_migrations (version) VALUES ('20090928135809');

INSERT INTO schema_migrations (version) VALUES ('20090930130031');

INSERT INTO schema_migrations (version) VALUES ('20091111170552');

INSERT INTO schema_migrations (version) VALUES ('20091125165700');

INSERT INTO schema_migrations (version) VALUES ('20091209083948');

INSERT INTO schema_migrations (version) VALUES ('20100118200011');

INSERT INTO schema_migrations (version) VALUES ('20100203222610');

INSERT INTO schema_migrations (version) VALUES ('20100223090310');

INSERT INTO schema_migrations (version) VALUES ('20100319183758');

INSERT INTO schema_migrations (version) VALUES ('20100528111406');

INSERT INTO schema_migrations (version) VALUES ('20100610103525');

INSERT INTO schema_migrations (version) VALUES ('20100614160217');

INSERT INTO schema_migrations (version) VALUES ('20100619104047');

INSERT INTO schema_migrations (version) VALUES ('20100623123943');

INSERT INTO schema_migrations (version) VALUES ('20100727160912');

INSERT INTO schema_migrations (version) VALUES ('20100806222042');

INSERT INTO schema_migrations (version) VALUES ('20100811134357');

INSERT INTO schema_migrations (version) VALUES ('20100827095717');

INSERT INTO schema_migrations (version) VALUES ('20101002144342');

INSERT INTO schema_migrations (version) VALUES ('20101025095028');

INSERT INTO schema_migrations (version) VALUES ('20101028135817');

INSERT INTO schema_migrations (version) VALUES ('20101111142814');

INSERT INTO schema_migrations (version) VALUES ('20101118151432');

INSERT INTO schema_migrations (version) VALUES ('20101130155457');

INSERT INTO schema_migrations (version) VALUES ('20101213183358');

INSERT INTO schema_migrations (version) VALUES ('20101216161948');

INSERT INTO schema_migrations (version) VALUES ('20101223133610');

INSERT INTO schema_migrations (version) VALUES ('20110124150835');

INSERT INTO schema_migrations (version) VALUES ('20110128143744');

INSERT INTO schema_migrations (version) VALUES ('20110301125220');

INSERT INTO schema_migrations (version) VALUES ('20110328122446');

INSERT INTO schema_migrations (version) VALUES ('20110330150317');

INSERT INTO schema_migrations (version) VALUES ('20110415133056');

INSERT INTO schema_migrations (version) VALUES ('20110505180606');

INSERT INTO schema_migrations (version) VALUES ('20111114110014');

INSERT INTO schema_migrations (version) VALUES ('20111114110109');

INSERT INTO schema_migrations (version) VALUES ('20111208131742');

INSERT INTO schema_migrations (version) VALUES ('20111212073809');

INSERT INTO schema_migrations (version) VALUES ('20111221132442');

INSERT INTO schema_migrations (version) VALUES ('20111221142909');

INSERT INTO schema_migrations (version) VALUES ('20120111104043');

INSERT INTO schema_migrations (version) VALUES ('20120111133855');

INSERT INTO schema_migrations (version) VALUES ('20120113221603');

INSERT INTO schema_migrations (version) VALUES ('20120119000000');

INSERT INTO schema_migrations (version) VALUES ('20120119000001');

INSERT INTO schema_migrations (version) VALUES ('20120119000002');

INSERT INTO schema_migrations (version) VALUES ('20120119000004');

INSERT INTO schema_migrations (version) VALUES ('20120207000000');

INSERT INTO schema_migrations (version) VALUES ('20120207000001');

INSERT INTO schema_migrations (version) VALUES ('20120208170529');

INSERT INTO schema_migrations (version) VALUES ('20120210163904');

INSERT INTO schema_migrations (version) VALUES ('20120222104414');

INSERT INTO schema_migrations (version) VALUES ('20120222130503');

INSERT INTO schema_migrations (version) VALUES ('20120309092925');

INSERT INTO schema_migrations (version) VALUES ('20120320084327');

INSERT INTO schema_migrations (version) VALUES ('20120329162800');

INSERT INTO schema_migrations (version) VALUES ('20120418084332');

INSERT INTO schema_migrations (version) VALUES ('20120418100232');

INSERT INTO schema_migrations (version) VALUES ('20120423094303');

INSERT INTO schema_migrations (version) VALUES ('20120517074440');

INSERT INTO schema_migrations (version) VALUES ('20120518063958');

INSERT INTO schema_migrations (version) VALUES ('20120518065629');

INSERT INTO schema_migrations (version) VALUES ('20120518204323');

INSERT INTO schema_migrations (version) VALUES ('20120523133512');

INSERT INTO schema_migrations (version) VALUES ('20120525112013');

INSERT INTO schema_migrations (version) VALUES ('20120529113203');

INSERT INTO schema_migrations (version) VALUES ('20120530075215');

INSERT INTO schema_migrations (version) VALUES ('20120530092530');

INSERT INTO schema_migrations (version) VALUES ('20120530134100');

INSERT INTO schema_migrations (version) VALUES ('20120530144610');

INSERT INTO schema_migrations (version) VALUES ('20120530145437');

INSERT INTO schema_migrations (version) VALUES ('20120601060411');

INSERT INTO schema_migrations (version) VALUES ('20120601060725');

INSERT INTO schema_migrations (version) VALUES ('20120601112110');

INSERT INTO schema_migrations (version) VALUES ('20120601122143');

INSERT INTO schema_migrations (version) VALUES ('20120601130137');