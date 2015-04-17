module Concerns
  module Admin
    module VocabularyPermissions
      extend ActiveSupport::Concern

      included do
        before_action :find_and_set_vocabulary
      end

      module ClassMethods
        def define_actions_for(association)
          define_create_action_for association
          define_edit_action_for association
          define_update_action_for association
        end

        def define_create_action_for(association)
          define_method :create do
            @vocabulary.send(association).create!(permission_params)
            session[:vocabulary_id] = nil

            redirect_to send(redirect_path(association), @vocabulary),
                        flash: {
                          success: 'The Vocabulary ' \
                                   "#{success_message(association)} " \
                                   'Permission has been created.' }
          end
        end

        def define_edit_action_for(association)
          define_method :edit do
            @permission = @vocabulary.send(association).find(params[:id])
            association_foreign_key = parent_id(association)
            if params[association_foreign_key]
              @permission.send("#{association_foreign_key}=",
                               params[association_foreign_key])
            end
          end
        end

        def define_update_action_for(association)
          define_method :update do
            permission = @vocabulary.send(association).find(params[:id])
            permission.update!(permission_params)
            session[:vocabulary_id] = nil

            redirect_to send(redirect_path(association), @vocabulary),
                        flash: {
                          success: 'The Vocabulary ' \
                                   "#{success_message(association)} " \
                                   'Permission has been updated.' }
          end
        end
      end

      private

      def find_and_set_vocabulary
        @vocabulary = Vocabulary.find(params[:vocabulary_id])
      end

      def parent_id(association)
        "#{association_without_suffix(association)}_id".to_sym
      end

      def association_without_suffix(association)
        association.to_s.split('_')[0..-2].join('_')
      end

      def redirect_path(association)
        "admin_vocabulary_vocabulary_#{association}_url"
      end

      def success_message(association)
        success_message = association.to_s.split('_')
        success_message.take(success_message.length - 1).join(' ').titleize
      end
    end
  end
end
