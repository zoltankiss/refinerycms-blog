FactoryGirl.define do
  factory :blog_category, :class => Refinery::Blog::Category do
    sequence(
      :title,
      FactoryGirlCustomMethods.starting_sequence_index(Refinery::Blog::Category, 'title', /Shopping (\d*)/)
    ) { |n| "Shopping #{n}" }
  end
end
