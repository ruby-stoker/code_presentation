# frozen_string_literal: true

class GenerateSuggestionSignJob < GenerateJoinProjectNdaJob

  def perform(project_id, user_id)
    @project = Project.unscoped.includes(:boiler_pattern).find(project_id)
    @user = User.find(user_id)
    @membership = @project.memberships.where(user_id: @user.id).first

    raise 'Race condition detected' unless @user && @project && @membership
    process
  end

  protected

  def process
    # generate certificate for sign
    pdf_generator = PdfGenerator.new
    agreement = pdf_generator.generate do
      ApplicationController.render('suggest_projects/suggestion_sign_details_for_pdf.html.erb',
                                   layout: false,
                                   assigns: { user: @user, project: @project })
    end
    # agreement = pdf_generator.file_path
    cert = seal_sign(IO.binread(agreement))
    @membership.update(certificate: cert)
  end
end
