class My::NotificationsController < ApplicationController

  before_action do
    auth_authorize :dashboard, :logged_in?
  end

  def update
    attrs = params.permit(notification: [:acknowledged]).fetch(:notification, {})
    id = params.require(:id)
    notification = current_user.notifications.find(id)
    notification.update!(attrs)
    render json: notification
  end

  def acknowledge_all
    notification_case_label = params.require(:notification_case_label)
    via_delegation_id = params.fetch(:via_delegation_id)
    notifications = current_user.notifications
      .where(acknowledged: false)
      .where(notification_case_label: notification_case_label)
      .where(via_delegation_id: via_delegation_id)
    notifications.update_all(acknowledged: true)
    render json: []
  end

  def acknowledge_multiple
    notification_ids = params.require(:notification_ids)
    notifications = current_user.notifications.where(id: notification_ids, acknowledged: false)
    notifications.update_all(acknowledged: true)
    render json: []
  end

end
