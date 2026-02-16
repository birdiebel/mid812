WickedPdf.configure do |c|
  c.exe_path = Gem.bin_path("wkhtmltopdf-binary", "wkhtmltopdf")

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # c.layout = 'pdf.html'
end
