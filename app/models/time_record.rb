class TimeRecord < ActiveRecord::Base
  MAX_MINUTES_ELAPSED = 10 * 60

  belongs_to :user

  belongs_to :project
  belongs_to :assignee, class_name: 'User', foreign_key: :assigned_to

  has_one :time_record_account, :dependent => :destroy
  has_one :account, :through => :time_record_account

  has_many :emails, :as => :mediator
  serialize :subscribed_users, Set

  uses_user_permissions
  acts_as_commentable
  has_paper_trail
  exportable

  sortable :by => ["rate DESC", "minutes_elapsed DESC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"

  has_ransackable_associations %w(user assignee account project activities)

  before_save :update_rate

  validates :date_started, presence: true
  validates :category, :inclusion => { :in => Proc.new { Setting.unroll(:time_tracking_rate_names).map { |s| s.last.to_s } } }
  validates :minutes_elapsed, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_MINUTES_ELAPSED }, if: :time_spent_valid?
  validates_numericality_of :rate, :allow_nil => true

  validate :validate_time_spent

  # Time Record created by the user for herself, or assigned to her by others.
  scope :my, ->(*args) {
    options = args[0] || {}
    user_option = (options.is_a?(Hash) ? options[:user] : options) || User.current_user
    includes(:assignee).
        where('(user_id = ? AND assigned_to IS NULL) OR assigned_to = ?', user_option, user_option).
        order(options[:order] || 'created_at ASC').
        limit(options[:limit]) # nil selects all records
  }

  # Search by name OR id
  scope :text_search, ->(query) {
    search('description_or_target_or_project_name_or_account_name_or_assignee_first_name_or_assignee_last_name_cont' => query).result
  }

  scope :created_by,  ->(user) { where(user_id: user.id ) }
  scope :assigned_to, ->(user) { where(assigned_to: user.id ) }

  # Time Record assigned by the user to others. That's what we see on TimeRecord/Assigned.
  scope :assigned_by, ->(user) {
    includes(:assignee).
      where('user_id = ? AND assigned_to IS NOT NULL AND assigned_to != ?', user.id, user.id)
  }

  # Time Record created by the user or assigned to the user, i.e. the union of the two
  # scopes above. That's the tasks the user is allowed to see and track.
  scope :tracked_by, ->(user) {
    includes(:assignee).
        where('user_id = ? OR assigned_to = ?', user.id, user.id)
  }

  def time_spent
    @time_spent ||= begin
      (minutes_elapsed / 60.0).round(2)
    rescue
      ''
    end
  end

  def time_spent=(value)
    @time_spent = begin
      timespan = Timespan.new("#{Float(value.to_s)} hrs")
      self.minutes_elapsed = timespan.to_minutes
      value.to_s
    rescue
      ''
    end
  end

  def save_with_account(params)
    params[:account].delete(:id) if params[:account][:id].blank?
    account = Account.create_or_select_for(self, params[:account])
    self.time_record_account = TimeRecordAccount.new(:account => account, :time_record => self) unless account.id.blank?
    self.account = account
    result = self.save
    result
  end

  def update_with_account(params)
    if params[:account] && (params[:account][:id] == "" || params[:account][:name] == "")
      self.account = nil
    elsif params[:account]
      account = Account.create_or_select_for(self, params[:account])
      if self.account != account and account.id.present?
        self.time_record_account = TimeRecordAccount.new(:account => account, :time_record => self)
      end
    end
    self.reload
    self.attributes = params[:time_record]
    self.save
  end

  protected

  def update_rate
    self.rate = Setting[:time_tracking_rates][self.category]
  end

  def validate_time_spent
    errors.add(:time_spent, I18n.t(:blank, scope: [:activerecord, :errors, :messages])) unless time_spent_valid?
  end

  def time_spent_valid?
    !(time_spent.nil? || time_spent.strip == '')
  end

end
