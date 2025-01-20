Rails.application.routes.draw do
  # Route racine
  root "home#index"

  # Routes d'authentification
  devise_for :companies
  devise_for :employees, skip: [:registrations]

  # Routes d'activation des employés (les mettre avant les autres routes employees)
  get 'employees/activate/:token', to: 'employees#activate', as: 'activate_employee'
  patch 'employees/set_password/:token', to: 'employees#set_password', as: 'set_employee_password'

  # Namespace pour les routes employés connectés
  namespace :employee do
    resources :surveys, only: [:index, :show] do
      member do
        get :answer_theme
        post :complete
        get :results
        get :qvt_results  # Nouvelle route pour voir les résultats QVT
      end
      resources :responses, only: [:create, :update]
      resources :custom_values, only: [:new, :create]
      # Nouvelles routes pour les réponses QVT
      resources :qvt_responses, only: [:create, :update] do
        collection do
          post :submit_page  # Pour soumettre une page entière de réponses QVT
        end
      end
    end
  end

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :value_categories
    resources :companies
    resources :surveys
    resources :employees
    resources :company_values
    # Routes pour QVT
    resources :qvt_themes do
      member do
        get :preview
      end
      resources :qvt_questions do
        resources :qvt_choices
      end
    end
  end

  # Routes pour l'interface administration (entreprise)
  resources :surveys do
    member do
      post :send_reminders
      get :results
      get :qvt_results
      get :rankings
      get :custom_values
      get :download_custom_values
      get :qvt_summary
      get :export_qvt
    end

    # Nouvelles routes pour la gestion des employés par sondage
    resources :survey_employees do
      collection do
        post :import
        get :download_template
        post :send_reminders
      end
      member do
        post :reinvite
      end
    end
  end

  resources :employees do
    member do
      post :reinvite
    end
    collection do
      post :import
      get :download_template
    end
  end

  # Routes pour les réponses aux valeurs
  resources :company_values, only: [] do
    resources :responses, only: [:create, :update]
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
