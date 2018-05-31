module Spree
  module Api
    module V1
      UsersController.class_eval do
        before_action :authenticate_user, except: [:forgot_password, :sign_up, :sign_in]

        def sign_up
          @user = Spree.user_class.find_by_email(params[:user][:email])

          if @user.present?
            render 'spree/api/v1/users/user_exists', status: 422 and return
          end

          @user = Spree.user_class.new(
            user_params.slice( :email, :password, :password_confirmation)
          )

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

        def update_password
          @user = current_api_user

          unless @user.update_with_password(password_params)
            render 'spree/api/v1/users/password_error', status: 422 and return
          end

          render json: { message: 'Updated Password', status: 'success' }
        end

        def forgot_password
          @user = Spree.user_class.find_by_email(params[:user][:email])

          unless @user.present?
            render 'spree/api/v1/users/no_such_email', status: 422 and return
          end

          token = @user.send(:set_reset_password_token)

          render json: { token: token }
        end

        protected

        def user_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end

        def password_params
          params.require(:user).permit(:password, :password_confirmation, :current_password)
        end
      end
    end
  end
end
