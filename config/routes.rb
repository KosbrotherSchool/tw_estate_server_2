require 'sidekiq/web'
TwEstateCrawlApp::Application.routes.draw do
 	mount Sidekiq::Web, at: '/sidekiq'

	namespace :api do
	namespace :v1 do
	  resources :estate, :only => [:index, :show] do
	    collection do
	      get 'around_all_by_areas'
	      get 'get_estate_item'
	      # get 'around_all'
	      # get 'estate_around'
	      # get 'presale_around'
	      # get 'rent_around'
	      # get 'estate_and_pre_sale_around'
	      # get 'estate_and_rent_around'
	      # get 'pre_sale_and_rent_around'
	    end
	  end
	end
	end


end
