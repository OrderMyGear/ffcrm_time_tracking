class TimeRecordsController < EntitiesController
  before_filter :load_settings
  before_filter :set_params, :only => [ :index, :redraw, :filter ]

  # GET /time_records
  #----------------------------------------------------------------------------
  def index
    @time_records = get_time_records(:page => params[:page])

    respond_with @time_records do |format|
      format.xls { render :layout => 'header' }
      format.csv { render :csv => @time_records }
    end
  end

  # GET /time_records/new
  #----------------------------------------------------------------------------
  def new
    @time_record.attributes = {:user => current_user, :assigned_to => current_user, :date_started => Date.current}
    @account  = Account.new(:user => current_user, :access => Setting.default_access)
    @accounts = Account.my.order('name')

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    if @project && @project.account
      @account = @project.account
    end

    respond_with(@time_record)
  end

  # GET /time_records/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @time_record = TimeRecord.tracked_by(current_user).find(params[:id])
    @account   = @time_record.account || Account.new(:user => current_user)
    @accounts  = Account.my.order('name')

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = TimeRecord.my.find_by_id($1) || $1.to_i
    end

    respond_with(@time_record)
  end

  # POST /time_records
  #----------------------------------------------------------------------------
  def create
    respond_with(@time_record) do |format|
      unless @time_record.save_with_account(params)
        @accounts = Account.my.order('name')
        unless params[:account][:id].blank?
          @account = Account.find(params[:account][:id])
        else
          if request.referer =~ /\/accounts\/(\d+)\z/
            @account = Account.find($1) # related account
          else
            @account = Account.new(:user => current_user)
          end
        end
      end
    end
  end

  # PUT /time_records/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@time_record) do |format|
      unless @time_record.update_with_account(params)
        @accounts = Account.my.order('name')
        if @time_record.account
          @account = Account.find(@time_record.account.id)
        else
          @account = Account.new(:user => current_user)
        end
      end
    end
  end

  # DELETE /time_records/1
  #----------------------------------------------------------------------------
  def destroy
    @time_record.destroy

    respond_with(@time_record) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # GET /time_records/redraw                                                      AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:time_records_per_page] = params[:per_page] if params[:per_page]

    # Sorting and naming only: set the same option for Contacts if the hasn't been set yet.
    if params[:sort_by]
      current_user.pref[:time_records_sort_by] = TimeRecord::sort_by_map[params[:sort_by]]
    end

    if params[:naming]
      current_user.pref[:time_records_naming] = params[:naming]
    end

    @time_records = get_time_records(:page => 1, :per_page => params[:per_page]) # Start one the first page.
    set_options # Refresh options

    respond_with(@time_records) do |format|
      format.js { render :index }
    end
  end

  # POST /time_records/filter                                                     AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:time_records_filter] = params[:status]
    @time_records = get_time_records(:page => 1, :per_page => params[:per_page]) # Start one the first page.

    respond_with(@time_records) do |format|
      format.js { render :index }
    end
  end

  private

  alias :get_time_records :get_list_of_records

  def set_params
    current_user.pref[:time_records_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:time_records_sort_by]  = TimeRecord::sort_by_map[params[:sort_by]] if params[:sort_by]
  end

  def load_settings
    @category = Setting.unroll(:time_tracking_rate_names)
  end

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      if called_from_index_page?                  # Called from Leads index.
        @time_records = get_time_records          # Get time_records for current page.
        if @time_records.blank?                   # If no time_record on this page then try the previous one.
          @time_records = get_time_records(:page => current_page - 1) if current_page > 1
          render :index and return                # And reload the whole list even if it's empty.
        end
      else                                        # Called from related asset.
        self.current_page = 1                     # Reset current page to 1 to make sure it stays valid.
      end                                         # Render destroy.js
    else # :html destroy
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, 'time record')
      redirect_to time_records_path
    end
  end
end