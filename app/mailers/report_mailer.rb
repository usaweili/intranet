class ReportMailer < ActionMailer::Base
  default :from => 'intranet@joshsoftware.com',
          :reply_to => 'hr@joshsoftware.com'
  
  def send_resource_categorisation_report(options, emails)
    data_file  = render_to_string(
      layout: false, handlers: [:axlsx], formats: [:xlsx],
      template: 'report_mailer/export_resource_categorisation_report',
      locals: options
    )

    attachment = { mime_type: Mime[:xlsx],
                   content: data_file }

    attachments["ResourceCategorisationReport - #{Date.today}.xlsx"] = attachment
    mail(
      subject: "Resource Categorisation Report - #{Date.today}",
      to: emails
    )
  end
end
