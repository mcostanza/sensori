# NOTE: environment variables are set on production server from elastic beanstalk configuration.
#       use https://console.aws.amazon.com/elasticbeanstalk/home?region=us-west-1 or elastic beanstalk CLI tools to edit.
access_key = ENV['AWS_ACCESS_KEY_ID'].present? ? ENV['AWS_ACCESS_KEY_ID'] : APP_CONFIG['aws']['access_key_id']
secret_key = ENV['AWS_SECRET_KEY'].present?    ? ENV['AWS_SECRET_KEY']    : APP_CONFIG['aws']['secret_access_key']

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base, :access_key => access_key, :secret_access_key => secret_key
  