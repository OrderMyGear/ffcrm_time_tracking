Rails.application.routes.draw do
  resources :time_records do
    collection do
      get  :advanced_search
      post :filter
      get  :redraw
      get  :versions
    end
  end
end
