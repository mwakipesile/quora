class DeviseMailer < Devise::Mailer
  include Resque::Mailer
  default :sender => Setting.smtp_username
  helper :application,:users,:asks
  layout "mailer"

  private
  # Configure default email options
  def setup_mail(record, action)

    record = hack_record(record)

    @scope_name     = Devise::Mapping.find_scope!(record)
    @devise_mapping = Devise.mappings[@scope_name]
    @resource       = instance_variable_set("@#{@devise_mapping.name}", record)

    headers = {
      :subject => translate(@devise_mapping, action),
      :from => mailer_sender(@devise_mapping),
      :to => record.email,
      :template_path => template_paths,
    }

    headers.merge!(record.headers_for(action)) if record.respond_to?(:headers_for)
    mail(headers) do |format|
      format.html { render "app/views/devise/mailer/#{action}" }
    end
  end

  protected
  # monkey patch :D
  def hack_record(record)
    record.kind_of?(Hash) ? User.find(record['_id']) : record
  end

end

