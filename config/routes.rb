Refinery::Core::Engine.routes.draw do
  namespace :blog, :path => Refinery::Blog.page_url do
    root :to => "posts#index"
    resources :posts, :only => [:show]

    get 'feed.rss', :to => 'posts#index', :as => 'rss_feed', :defaults => {:format => "rss"}
    get 'categories/:id', :to => 'categories#show', :as => 'category'
    post ':id/comments', :to => 'posts#comment', :as => 'comments'
    get 'archive/:year(/:month)', :to => 'posts#archive', :as => 'archive_posts'
    get 'tagged/:tag_id(/:tag_name)' => 'posts#tagged', :as => 'tagged_posts'
  end

  # todo: fix this... lol
  get 'refinery/blog/ajax_search' => 'blog/admin/posts#ajax_search', as: 'ajax_search'

  namespace :blog, :path => '' do
    namespace :admin, :path => Refinery::Core.backend_route do
      scope :path => Refinery::Blog.page_url do
        root :to => "posts#index"

        resources :posts do
          collection do
            get :uncategorized
            get :tags
          end
        end

        resources :categories

        resources :comments do
          collection do
            get :approved
            get :rejected
          end
          member do
            post :approve
            post :reject
          end
        end

        resources :settings do
          collection do
            get :notification_recipients
            post :notification_recipients

            get :moderation
            get :comments
            get :teasers
          end
        end
      end
    end
  end
end
