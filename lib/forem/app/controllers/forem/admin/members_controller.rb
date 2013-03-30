module Forem
  module Admin
    class MembersController < BaseController
      def create
        user = Forem.user_class.where(Forem.autocomplete_field => params[:user]).first
        unless group.members.exists?(user.id)
          group.members << user
        end
        render :status => :ok
      end

      private

      def group
        @group ||= Forem::Group.find(params[:group_id])
      end
    end
  end
end
