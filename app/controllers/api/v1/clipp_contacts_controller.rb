class Api::V1::ClippContactsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_filter :restrict_access

  def contact_clipp
    @clipps_contact = ClippContact.new(clipp_contacts_params)
    if @clipps_contact.valid?
      ClippMailer.delay.contact_us(clipp_contacts_params)
      render json: { text: 'Mail sent' }, status: :ok
    else
      render json: { errors: @clipps_contact.errors.full_messages.join(",")}, status: :unprocessable_entity
    end
  end

  private

  def clipp_contacts_params
    params.permit(:name, :email, :website, :phone, :comment)
  end

  def restrict_access
    host = URI(request.referer).host if request.referer.present?
    head :unauthorized unless(host.present? && (host.match(/clipp\.tv/)))
  end

end
