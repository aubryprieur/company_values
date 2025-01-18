WickedPdf.configure do |config|
  config.exe_path = Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
  config.javascript_delay = 1000
  config.enable_local_file_access = true
  config.window_status = 'ready'
end
