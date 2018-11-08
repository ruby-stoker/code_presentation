# frozen_string_literal: true

class JoinProjectService
  def self.join(project, user, strategy = false)
    case strategy
      when 'boiler'
        project.status = Project::STATUS_ONGOING
        return false unless project.save
        GenerateJoinBoilerNdaJob.perform_later(project.id, user.id)
      when 'suggestion'
        GenerateSuggestionSignJob.perform_later(project.id, user.id)
      else
        membership = project.memberships.new(user: user)
        return false unless membership.save
        GenerateJoinProjectNdaJob.perform_later(project.id, user.id)
    end
    true
  end
end
