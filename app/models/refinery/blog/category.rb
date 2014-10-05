module Refinery
  module Blog
    class Category < ActiveRecord::Base
      extend FriendlyId

      translates :title, :slug

      friendly_id :title, :use => [:slugged, :globalize]

      has_many :categorizations, :dependent => :destroy, :foreign_key => :blog_category_id
      has_many :posts, :through => :categorizations, :source => :blog_post

      validates :title, :presence => true, :uniqueness => true

      def self.translated
        with_translations(::Globalize.locale)
      end

      def post_count
        posts.live.with_globalize.count
      end

      def define_parent(parent)
        CategoryLink.find_or_create_by!(parent_id: parent.id, child_id: self.id)
      end

      def undefine_parent(parent)
        CategoryLink.where(parent_id: parent.id, child_id: self.id).first.try :destroy
      end

      def parents
        links = CategoryLink.where(child_id: self.id).to_a
        if links.blank?
          links
        else
          links.map { |link| link.parent }
        end
      end

      def children
        links = CategoryLink.where(parent_id: self.id).to_a
        if links.blank?
          links
        else
          links.map { |link| link.child }
        end
      end

      # how many items to show per page
      self.per_page = Refinery::Blog.posts_per_page

    end
  end
end
