class PrelaunchSignup < ActiveRecord::Base
  attr_accessible :email
  
  validates :email, :presence => true, :uniqueness => true

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |prelaunch_signup|
        csv << prelaunch_signup.attributes.values_at(*column_names)
      end
    end
  end
end
