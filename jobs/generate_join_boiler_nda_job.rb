# frozen_string_literal: true

class GenerateJoinBoilerNdaJob < GenerateJoinProjectNdaJob

  def perform(project_id, user_id)
    @project = Project.unscoped.includes(:boiler_pattern).find(project_id)
    @user = User.find(user_id)
    @boiler_pattern = @project.boiler_pattern
    @membership = @project.memberships.where(user_id: @user.id).first

    raise 'Race condition detected' unless @user && @project && @boiler_pattern.agreement.attached? && @membership
    process
  end

  protected

  def process
    # generate certificate for sign
    cert = seal_sign(@boiler_pattern.agreement.download)
    @membership.update(certificate: cert)

    # generate details pdf
    details_generator = PdfGenerator.new
    details_generator.generate do
      ApplicationController.render('join_project/nda_details_for_pdf.html.erb',
                                   layout: false,
                                   assigns: { user: @user, project: @project, cert: @cert })
    end
    @details_pdf_path = details_generator.file_path

    # attach signed agreement to Membership
    @membership.signed_agreement.attach(io: File.open(@details_pdf_path),
                                        filename: @project.signed_nda_filename(@user))
  end
end
