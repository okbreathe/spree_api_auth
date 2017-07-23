Spree::Core::Engine.add_routes do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resource :users do
        post :sign_up
        post :sign_in
      end
    end
  end
end
