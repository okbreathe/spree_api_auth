module Spree
  module Api
    module V1
      UsersController.class_eval do
        before_action :authenticate_user, :except => [:sign_up, :sign_in]

        def sign_up
          @user = Spree.user_class.find_by_email(params[:user][:email])

          if @user.present?
            render "spree/api/v1/users/user_exists", :status => 400 and return
          end

          @user = Spree.user_class.new(user_params)
          if !@user.save
            invalid_resource! @user
            return
          end
          @user.generate_spree_api_key!
        end

        def sign_in
          @user = Spree.user_class.find_by_email(params[:user][:email])
          if !@user.present? || !@user.valid_password?(params[:user][:password])
            render 'invalid', status: 401
            return
          end
          @user.generate_spree_api_key! if @user.spree_api_key.blank?
        end

        def user_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
