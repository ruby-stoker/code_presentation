# frozen_string_literal: true

module AttachmentValidator
  extend ActiveSupport::Concern

  included do
    def self.validate_attachment_size(field, size)
      validate "#{field}_max_file_size".to_sym

      define_method "#{field}_max_file_size".to_sym do
        if send(field).attached? && send(field).blob.byte_size > size
          send(field).purge
          errors.add(field, "allowed file size is #{bytes_to_megabytes(size)} bytes max")
        end
      end
    end

    def self.validate_attachment_type(field, types)
      validate "#{field}_file_type".to_sym

      define_method "#{field}_file_type".to_sym do
        if send(field).attached? && !types.include?(send(field).content_type)
          send(field).purge
          format_types = types.map do |item|
            item.split('/').last
          end.join(' ,')
          errors.add(field, if types.length == 1
                              "Not allowed type of file! Allowed type is only #{format_types}"
                            else
                              "Not allowed type of file! Allowed types are #{format_types}"
                            end)
        end
      end
    end

    def self.validate_attachment_presence(field)
      validate "#{field}_presence".to_sym

      define_method "#{field}_presence".to_sym do
        errors.add(field, "can't be blank") unless send(field).attached?
      end
    end
  end

  private

  def bytes_to_megabytes(bytes)
    (bytes.to_f / 1024 / 1024 * 100).round / 100.0
  end
end
