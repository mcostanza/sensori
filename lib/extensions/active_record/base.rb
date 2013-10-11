module ActiveRecord
  class Base
    after_create :set_just_created

    def just_created?
      !!@just_created
    end

    private

    def set_just_created
      @just_created = true
    end
  end
end
