Dir.glob(File.join(Rails.root, 'lib/extensions', '**', '*.rb')).each { |f| require f }
