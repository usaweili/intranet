class ClippMailer < ActionMailer::Base
  default :from => 'intranet@joshsoftware.com', :reply_to => 'info@clipp.tv'

  def contact_us(clipp_contacts_params)
    @clipp_contact = clipp_contacts_params
    mail(subject: 'New comment from website!', to: 'info@clipp.tv')
  end
end
