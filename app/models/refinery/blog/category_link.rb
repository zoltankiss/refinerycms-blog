module Refinery
  module Blog
    class CategoryLink < ActiveRecord::Base
      belongs_to :parent, class_name: 'Refinery::Blog::Category'
      belongs_to :child, class_name: 'Refinery::Blog::Category'
    end
  end
end