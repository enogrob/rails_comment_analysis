Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Legacy route for AnalyzeController (for test coverage)
  post '/analyze', to: 'analyze#create'
  # Main route for AnalysisController
  post '/analysis', to: 'analysis#create'
  get '/progress/:job_id', to: 'progress#show'
  resources :keywords
end
