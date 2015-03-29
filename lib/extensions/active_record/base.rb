module JustCreated
  def self.included(base)
    base.send(:after_create, :set_just_created)
  end

  def just_created?
    !!@just_created
  end

  private

  def set_just_created
    @just_created = true
  end
end

ActiveRecord::Base.send(:include, JustCreated)
