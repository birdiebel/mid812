WickedPdf.configure do |c|
  env_path = ENV["WKHTMLTOPDF_PATH"]
  c.exe_path = if env_path && !env_path.empty?
    env_path
  elsif File.executable?("/usr/bin/wkhtmltopdf")
    "/usr/bin/wkhtmltopdf"
  else
    "wkhtmltopdf"
  end

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # c.layout = 'pdf.html'
end
