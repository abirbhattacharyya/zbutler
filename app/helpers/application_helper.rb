# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_user
    @current_user ||= User.find_by_fb_uid(session[:user_id])
    return @current_user
  end

  def fb_app_id
    ((Rails.env.production?) ? '269802526423298' : '104941819581482')
  end

  def get_all_fb_user_ids
    fb_users = User.find(:all,:conditions => ["fb_uid IS NOT NULL"]).map(&:fb_uid)
    return fb_users
  end

end
