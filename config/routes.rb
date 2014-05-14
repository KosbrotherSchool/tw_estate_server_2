require 'sidekiq/web'
TwEstateCrawlApp::Application.routes.draw do
 	mount Sidekiq::Web, at: '/sidekiq'

	namespace :api do
		namespace :v1 do
		  resources :estate, :only => [:index, :show] do
		    collection do
		      get 'around_all_by_areas'
		      get 'get_estate_item'

		      get 'get_around_estates'
		      get 'get_estates_by_ids'
		      get 'get_estate_details'
		      get 'get_estate_by_distance'
		      get 'get_current_crawl_data'
		    end
		  end
		end
	end

	namespace :api do
		namespace :v2 do
		  resources :estate, :only => [:index, :show] do
		    collection do
		      get 'get_estate_details'
		      get 'get_estate_by_distance'
		      get 'get_month_data'
		      post 'post_lender'
		    end
		  end
		end
	end

end
