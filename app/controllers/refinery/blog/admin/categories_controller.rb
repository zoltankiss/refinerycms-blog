module Refinery
  module Blog
    module Admin
      class CategoriesController < ::Refinery::AdminController

        crudify :'refinery/blog/category',
                :order => 'title ASC'

        def create
          permitted = params.require(:category).permit(:parent_id, :title)
          if Category.create(permitted)
            flash.notice = t(
              'refinery.crudify.created',
              :what => 'Category'
            )

            create_or_update_successful
          else
            create_or_update_unsuccessful 'edit'
          end
        end

        private

        def category_params
          params.require(:category).permit(:title)
        end
      end
    end
  end
end
