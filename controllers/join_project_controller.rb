# frozen_string_literal: true

class JoinProjectController < ApplicationController
  before_action :set_project
  before_action :set_membership, only: %i[check_nda signed_nda]

  # POST /projects/:project_id/join/confirm_nda/:strategy
  def confirm_nda
    redirect_to project_path(@project), flash: { alert: "You've joined to this project already." } and return if @project.signed?(current_user)
    redirect_to signed_nda_project_join_path(@project) if JoinProjectService.join(@project, current_user, params[:strategy])
  end

  private

  def set_project
    @project = policy_scope(Project.unscoped, policy_scope_class: JoinProjectPolicy::Scope).find(params[:project_id])
    authorize @project, :join?
  end

  def set_membership
    @membership = @project.memberships.where(user: current_user).first
  end
end