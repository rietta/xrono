module ApplicationHelper
  include Acl9Helpers

  def bootstrap_icon(name)
    content_tag('i', nil, :class => "icon-#{name}")
  end

  def external_work_percentage(user, start_date, end_date)
    if @site_settings.client
      internal = user.percentage_work_for(@site_settings.client, start_date, end_date)
      (100 - internal).to_s
    end
  end

  def last_effective_date(start_date)
    if start_date.end_of_week > Date.current 
      Date.current
    else
      start_date.end_of_week
    end
  end
  
  

  def render_label_for(hour_type)
    label_type = nil
    case hour_type
    when 'Overtime'
      label_type = 'important'
    when 'PTO'
      label_type = 'success'
    when 'CTO'
      label_type = 'warning'
    end
    if label_type
      haml_tag(:div, :class => 'label ' << label_type) do
        haml_concat hour_type
      end
    end
  end

  def project_completion_metric(project)
    work_unit_hours_array = Array.new # Empty array to work with

    # Take the summation of estimated_hours on a ticket from the project
    estimated_hours = Ticket.for_project(project).sum(:estimated_hours)
    
    # Push the work unit hours in if the ticket on the project has estimated hours
    work_unit_hours = WorkUnit.for_project(project).on_estimated_ticket.sum(:hours)
    
    # Calculatre the projects completion as a percent
    percent = (((work_unit_hours / estimated_hours)).to_f * 100.00).to_i rescue 0
    [percent, 100].min # Make sure you don't go over 100 percent and confuse the graphs
  end
end
