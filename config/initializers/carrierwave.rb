CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => 'AKIAIUGACQ5Z6QHBIH3Q',
    :aws_secret_access_key  => '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'
  }
  config.fog_directory  = Rails.env == 'production' ? 'sensori' : 'sensori-dev'
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end
