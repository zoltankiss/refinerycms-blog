module Refinery
  module Blog
    class Category < ActiveRecord::Base
      extend FriendlyId

      translates :title, :slug

      friendly_id :title, :use => [:slugged, :globalize]

      has_many :categorizations, :dependent => :destroy, :foreign_key => :blog_category_id
      has_many :posts, :through => :categorizations, :source => :blog_post

      has_many :child_categories, foreign_key: :parent_id
      belongs_to :parent, class_name: 'Refinery::Blog::Category'

      validates :title, :presence => true, uniqueness: { scope: :parent_id }

      def self.translated
        with_translations(::Globalize.locale)
      end

      def post_count
        posts.live.with_globalize.count
      end

      def children
        self.class.where(parent_id: self.id)
      end

      # how many items to show per page
      self.per_page = Refinery::Blog.posts_per_page

    end
  end
end
