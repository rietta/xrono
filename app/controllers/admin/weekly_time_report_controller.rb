class Admin::WeeklyTimeReportController < ApplicationController

  def index
    #redirect_to('/admin/weekly_time_report/' + Date.current.beginning_of_week.strftime("%F"))
    redirect_to(admin_weekly_time_report_index_path + "/" + Date.current.beginning_of_week.strftime("%F"))
  end

  def show
    #redirect_unless_monday('/admin/weekly_time_report/', params[:id])
    redirect_unless_monday(admin_weekly_time_report_index_path, params[:id])
    @users = User.sort_by_name.select{|u| u.has_role?(:developer) && !u.locked }
    @weekly_hours_sum = external_hours_for_chart(@users, :date => @start_date)
  end

end
