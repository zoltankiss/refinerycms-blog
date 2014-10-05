class CreateCategoryLink < ActiveRecord::Migration
  def change
    create_table :category_links do |t|
      t.references :parent
      t.references :child
      t.timestamps
    end
  end
end
