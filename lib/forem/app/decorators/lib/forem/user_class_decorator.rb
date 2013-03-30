# Fix for #88
if Forem.user_class
  Forem.user_class.class_eval do
    extend Forem::Autocomplete
    include Forem::DefaultPermissions

    has_many :forem_posts, :class_name => "Forem::Post", :foreign_key => "user_id"
    has_many :forem_topics, :class_name => "Forem::Topic", :foreign_key => "user_id"
    has_many :forem_memberships, :class_name => "Forem::Membership", :foreign_key => "member_id"
    has_many :forem_groups, :through => :forem_memberships, :class_name => "Forem::Group", :source => :group

    def forem_needs_moderation?
      !Forem.moderate_first_post || forem_state == 'approved'
    end
  end
end
