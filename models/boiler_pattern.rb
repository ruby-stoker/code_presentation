# == Schema Information
#
# Table name: boiler_patterns
#
#  id               :bigint(8)        not null, primary key
#  challenge        :string
#  description      :string
#  expected_outcome :string
#  opportunity      :string
#  title            :string
#  we_bring         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  workspace_id     :bigint(8)
#
# Indexes
#
#  index_boiler_patterns_on_workspace_id  (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_id => workspaces.id)
#

class BoilerPattern < ApplicationRecord
  include AttachmentValidator

  has_one_attached :agreement

  validate_attachment_size :agreement, 5.megabytes
  validate_attachment_type :agreement, %w[application/pdf]
  validate_attachment_presence :agreement

  validates :title, presence: true
end
