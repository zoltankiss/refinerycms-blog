class AddParentIdToCategory < ActiveRecord::Migration
  def change
    add_column :refinery_blog_categories, :parent_id, :integer
  end
end
