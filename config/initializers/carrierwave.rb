CarrierWave.configure do |config|
  config.storage = :fog
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => APP_CONFIG['aws']['access_key_id'],
    :aws_secret_access_key  => APP_CONFIG['aws']['secret_access_key']
  }
  config.fog_directory  = APP_CONFIG['aws']['s3_bucket']
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
end

if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end
