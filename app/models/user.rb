class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :rememberable, :trackable, :validatable, :lockable, :token_authenticatable

  include Gravtastic
  gravtastic
  is_gravtastic!

  acts_as_authorization_subject :association_name => :roles, :join_table_name => :roles_users
  acts_as_tagger

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :middle_initial, :full_width,
                  :daily_target_hours, :expanded_calendar, :client

  validates_presence_of :first_name, :last_name
  validates_length_of :middle_initial, :is => 1, :allow_blank=>true

  has_many :work_units
  has_many :comments

  # Scopes
  def self.with_unpaid_work_units
    select('distinct users.*').joins(:work_units).where(:work_units => {:paid => [nil, '']})
  end

  scope :unlocked, where(:locked_at => nil)
  scope :locked,   where('locked_at IS NOT NULL')
  scope :sort_by_name, order('first_name ASC')
  scope :developers, lambda { joins("INNER JOIN roles r on r.authorizable_type='Project'").joins("INNER JOIN roles_users ru ON ru.role_id = r.id").joins("INNER JOIN users u ON ru.user_id = u.id").where("r.name = 'developer'").where("ru.user_id = users.id") }
  scope :for_project, lambda{|project|
    joins("INNER JOIN roles r ON r.authorizable_type='Project' AND r.authorizable_id=#{project.id}").joins("INNER JOIN roles_users ru ON ru.role_id = r.id").joins("INNER JOIN users u ON ru.user_id = u.id").where("ru.user_id = users.id")
  }

  # Return the initials of the User
  def initials
    "#{first_name[0,1]}#{middle_initial}#{last_name[0,1]}".upcase
  end

  def work_units_between(start_time, end_time)
    work_units.scheduled_between(start_time.beginning_of_day, end_time.end_of_day)
  end

  def work_units_for_day(time)
    work_units.scheduled_between(time.beginning_of_day, time.end_of_day)
  end

  def clients_for_day(time)
    work_units_for_day(time).map{|x| x.client}.uniq
  end

  def work_units_for_week(time)
    work_units.scheduled_between(time.beginning_of_week, time.end_of_week)
  end

  def hours_entered_for_day(time)
    hours = 0
    work_units_for_day(time).each do |w|
      hours += w.hours
    end
    hours
  end
  def unpaid_work_units
    work_units.unpaid
  end

  def to_s
    "#{first_name.capitalize} #{middle_initial.capitalize} #{last_name.capitalize}"
  end

  def client?
    @client ||= has_role?(:client)
  end

  def developer?
    @developer ||= has_role?(:developer)
  end

  def admin?
    @admin ||= has_role?(:admin)
  end

  def locked
    locked_at?
  end

  def pto_hours_left(date)
    raise "Date must be a date object" unless date.is_a?(Date)
    time = date.to_time_in_current_zone
    SiteSettings.first.total_yearly_pto_per_user - work_units.pto.scheduled_between(time.beginning_of_year, time).sum(:hours)
  end

  # TODO: refactor this mess
  def expected_hours(date)
    raise "Date must be a date object" unless date.is_a?(Date)
    # no expected hours if the user has never worked
    return 0 unless work_units.present?
    # set the user's first day by the first work unit
    first_day = work_units.first.scheduled_at.to_date
    # no expected hours if their first day is in the future
    return 0 if first_day > date
    if first_day.year == date.year
      # if their first day was in the same year as the date
      # calculate the offset of the first week, incase they dont start on monday
      first_week_offset = first_day.cwday - 1
      # caculate total days from previous week, subtracting the first week offset
      days_from_prev_weeks = ((date.cweek - first_day.cweek) * 5) - first_week_offset
      # get the number of work days in the targeted week that have passed
      days_from_cur_week = [date.cwday, 5].min
    else
      # user has been here all year, count total work days in year
      days_from_prev_weeks = (date.cweek - 1) * 5
      days_from_cur_week = [date.cwday, 5].min
    end
    # calculate expected hours off of total expected days
    (days_from_prev_weeks + days_from_cur_week) * daily_target_hours
  end

  def target_hours_offset(date)
    raise "Date must be a date object" unless date.is_a?(Date)
    worked_hours = WorkUnit.for_user(self).scheduled_between(date.beginning_of_year, date.end_of_day).sum(:hours)
    worked_hours - expected_hours(date)
  end

  def entered_time_yesterday?
    return true if !developer? || admin?
    previous_work_days_work_units.any?
  end

  def previous_work_days_work_units
    work_units_between(Date.current.prev_working_day.beginning_of_day, Date.current.prev_working_day.end_of_day)
  end

  def percentage_work_for(client, start_date, end_date)
    raise "client must be a Client instance" unless client.is_a?(Client)
    raise "Date must be a date object" unless start_date.is_a?(Date) && end_date.is_a?(Date)
    # note: I'm returning an integer here, as I think that is specific enough for the
    # reporting use case, this can easily be changed if future needs demand
    wu = work_units.scheduled_between(start_date.beginning_of_day, end_date.end_of_day)
    total_hours = wu.sum(:effective_hours)
    client_hours = wu.for_client(client).sum(:effective_hours)
    # Dividing by 0 is bad, mkay?
    total_hours == 0 ? 0 : ((100 * client_hours)/total_hours).round
  end
end
