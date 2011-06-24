class Admin::UnenteredTimeReportController < ApplicationController

  def index
    #redirect_to("/admin/unentered_time_report/#{Date.current.beginning_of_week.to_s}")
    redirect_to(admin_unentered_time_report_index_path + "/#{Date.current.beginning_of_week.to_s}")
  end

  def show
    #redirect_unless_monday('/admin/unentered_time_report/', params[:id])
    redirect_unless_monday(admin_unentered_time_report_index_path, params[:id])
    @week_dates = build_week_hash_for(Date.parse(params[:id]))
    @users = User.select{|u| u.has_role?(:developer) && !u.locked }
  end

end
