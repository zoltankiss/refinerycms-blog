module Refinery
  module Blog
    module Admin
      class PostsController < ::Refinery::AdminController

        crudify :'refinery/blog/post',
                :order => 'published_at DESC',
                :include => [:translations, :author]

        before_filter :find_all_categories,
                      :only => [:new, :edit, :create, :update]

        before_filter :check_category_ids, :only => :update

        before_filter :set_index_vars, only: :index

        def uncategorized
          @posts = Refinery::Blog::Post.uncategorized.page(params[:page])
        end

        def ajax_search
          query = params[:term].match(/(.*) \((.*)\)/)
          term = query[1]
          type = query[2]

          @categories = if type == 'category'
            Refinery::Blog::Category.where(title: term).all
          elsif type == 'post'
            # fixme this could be faster
            Refinery::Blog::Category.where(
              id: Refinery::Blog::Post.where(title: term).first.categories.map(&:top_most_parent).map(&:id)
            ).all
          else
            nil
          end

          render partial: "sortable_list"
        end

        def tags
          if ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
            op = '~*'
            wildcard = '.*'
          else
            op = 'LIKE'
            wildcard = '%'
          end

          @tags = Refinery::Blog::Post.tag_counts_on(:tags).where(
              ["tags.name #{op} ?", "#{wildcard}#{params[:term].to_s.downcase}#{wildcard}"]
            ).map { |tag| {:id => tag.id, :value => tag.name}}
          render :json => @tags.flatten
        end

        def new
          @post = ::Refinery::Blog::Post.new(:author => current_refinery_user)
        end

        def create
          # if the position field exists, set this object as last object, given the conditions of this class.
          if Refinery::Blog::Post.column_names.include?("position")
            post_params.merge!({
              :position => ((Refinery::Blog::Post.maximum(:position, :conditions => "")||-1) + 1)
            })
          end

          if (@post = Refinery::Blog::Post.create(post_params)).valid?
            (request.xhr? ? flash.now : flash).notice = t(
              'refinery.crudify.created',
              :what => "'#{@post.title}'"
            )

            unless from_dialog?
              unless params[:continue_editing] =~ /true|on|1/
                redirect_back_or_default(refinery.blog_admin_posts_path)
              else
                unless request.xhr?
                  redirect_to :back
                else
                  render "/shared/message"
                end
              end
            else
              render :text => "<script>parent.window.location = '#{refinery.blog_admin_posts_url}';</script>"
            end
          else
            unless request.xhr?
              render :new
            else
              render :partial => "/refinery/admin/error_messages",
                     :locals => {
                       :object => @post,
                       :include_object_name => true
                     }
            end
          end
        end

      private

        def set_index_vars
          @view = params[:view]
        end

        def post_params
          params.require(:post).permit(:title, :body, :custom_teaser, :tag_list,
            :draft, :published_at, :custom_url, :user_id, :browser_title,
            :meta_description, :source_url, :source_url_title, :category_ids => [])
        end

      protected

        def find_post
          @post = Refinery::Blog::Post.find_by_slug_or_id(params[:id])
        end

        def find_all_categories
          @categories = Refinery::Blog::Category.all
        end

        def check_category_ids
          post_params[:category_ids] ||= []
        end
      end
    end
  end
end
