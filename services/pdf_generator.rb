# frozen_string_literal: true

class PdfGenerator
  include RandomFilenameGenerator

  attr_reader :file_path

  PDF_PATH = 'tmp/pdfs'
  DEFAULT_PAGE_SIZE = 'A4'

  def generate
    Dir.mkdir(PDF_PATH) unless File.exist?(PDF_PATH)
    html_for_pdf = yield
    doc_pdf = WickedPdf.new.pdf_from_string(html_for_pdf, page_size: DEFAULT_PAGE_SIZE)
    @file_path = Rails.root.join(PDF_PATH, random_filename('pdf'))

    File.open(@file_path, 'wb') do |file|
      file << doc_pdf
    end
  end
end
