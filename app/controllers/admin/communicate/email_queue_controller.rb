class Admin::Communicate::EmailQueueController < Admin::BaseController
  before_filter :add_to_breadcrumbs, :except => [:check_queue_status]
  
  def index
    @select = params[:all] ? :all : :current_user
    @emails = EmailQueue.messages(@select)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @emails }
    end
  end

  def show
    @email = EmailQueue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email }
    end
    session[:breadcrumbs].add "View"
  end

  def new
    @email = EmailQueue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email }
    end
    session[:breadcrumbs].add "Create New"
  end

  def edit
    @email = EmailQueue.find(params[:id])
    session[:breadcrumbs].add "Edit E-mail (ID ##{@email.id})"
  end

  def create
    @email = EmailQueue.new(params[:email])

    respond_to do |format|
      if @email.save
        flash[:notice] = 'E-mail was successfully created.'
        format.html { redirect_to(@email) }
        format.xml  { render :xml => @email, :status => :created, :location => @email }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @email = EmailQueue.find(params[:id])
    @email.email.to = params[:t_mail_mail] ? params[:t_mail_mail][:to] : params[:mail_message][:to]
    @email.email.from = params[:t_mail_mail] ? params[:t_mail_mail][:from] : params[:mail_message][:from]
    @email.email.subject = params[:t_mail_mail] ? params[:t_mail_mail][:subject] : params[:mail_message][:subject]
    @email.email.cc = params[:t_mail_mail] ? params[:t_mail_mail][:cc] : params[:mail_message][:cc]
    @email.email.bcc = params[:t_mail_mail] ? params[:t_mail_mail][:bcc] : params[:mail_message][:bcc]
    @email.email.body = params[:t_mail_mail] ? params[:t_mail_mail][:body] : params[:mail_message][:body]

    respond_to do |format|
      if @email.save
        flash[:notice] = "E-mail was successfully updated and re-queued."
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @email = EmailQueue.find(params[:id])
    @email.destroy
    @emails = EmailQueue.find :all, :order => "updated_at DESC"

    respond_to do |format|
      format.js   { render :partial => "table" }
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
    end
  end

  def release
    if params[:select]
      if params[:delete]
        params[:select].each do |key,val|
          EmailQueue.find(val).destroy
        end
        flash[:notice] = "Messages deleted."
      elsif params[:release]
        ids = params[:select].collect{|key,val| val}.join(",")
        # Only use forked process if there are more than 25 messages
        if params[:select].size > 25          
          logger.info { "Initiating fork for email_queue:release" }
          @pid = fork do
            call_rake("email_queue:release", "email_queue", {:email_queue_ids => ids })
            # cmd = "/usr/bin/rake email_queue:release EMAIL_QUEUE_IDS=#{ids} RAILS_ENV=#{RAILS_ENV} --trace 2>&1 >> #{Rails.root}/log/email_queue.log"
            # logger.info { "Releasing emails from queue: #{cmd}" }
            # system cmd
            # exit! 127
          end
          Process.detach(@pid)
        else
          params[:select].each do |key,val|
            begin
              email = EmailQueue.find(val)
              email.release
            rescue ActiveRecord::RecordNotFound => e
              nil
            rescue Exception => e
              email.update_attribute(:error_details, e.message)
            end
          end
        end
      end
    end
    session[:return_to_after_email_queue] = nil
    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.js
    end
  end

  # Expects the same parameters as #release, but instead of kicking off sending the emails, returns some RJS that removes
  # sent emails from the browser display. Also expects a parameter called +pid+ which is the pid of the email queue rake
  # task. We check if that PID is still running, and if it is, we tell the browser that we're done and to stop checking status.
  def check_queue_status
    @sent_email_ids = []
    @error_emails = []
    if params[:select]
      params[:select].sort.each do |key,val|
        begin
          email = EmailQueue.find(val)
          @error_emails << email if email.error_details
        rescue ActiveRecord::RecordNotFound => e
          @sent_email_ids << val
        end
      end
    end
    if params[:pid]
      if params[:pid] == "true"
        @complete = true
      else
        begin
          @pid = params[:pid].to_i
          process = Process.getpgid(@pid)
        rescue Errno::ESRCH => e
          @complete = true
        end
      end
    end
    @email_count = EmailQueue.count
    respond_to do |format|
      format.js
    end
  end

  # def release
  #   if params[:select]
  #     if params[:delete]
  #       params[:select].each do |key,val|
  #         EmailQueue.find(val).destroy
  #       end
  #       flash[:notice] = "Messages deleted."
  #     elsif params[:release]
  #       params[:select].each do |key,val|
  #         begin
  #           EmailQueue.find(val).release
  #         rescue Exception
  #           flash[:error] << "Message # #{val} could not be sent: #{$!.message}" 
  #         end
  #       end
  #       flash[:notice] = "E-mails delivered successfully."
  #     end
  #   end
  #   if EmailQueue.messages_waiting?
  #     redirect_to :action => "index"
  #   else
  #     if session[:return_to_after_email_queue]
  #       redirect_to session[:return_to_after_email_queue] || { :action => 'index' }
  #       session[:return_to_after_email_queue] = nil 
  #       return
  #     else
  #       redirect_to :action => "index"
  #     end
  #   end
  # end

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "E-mail Queue", "/admin/communicate/email_queue"
  end
  
end
