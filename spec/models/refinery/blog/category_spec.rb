require 'spec_helper'

module Refinery
  module Blog
    describe Category, type: :model do
      let(:category) { FactoryGirl.create(:blog_category) }
      let(:refinery_user) { FactoryGirl.create(:refinery_user) }

      context 'parent and children' do
        before(:all) do
          @parent_a = FactoryGirl.create(:blog_category)
          @parent_b = FactoryGirl.create(:blog_category)
          @child_of_a = FactoryGirl.create(:blog_category)
          @child_of_b = FactoryGirl.create(:blog_category)
          @child_of_a.define_parent(@parent_a)
          @child_of_b.define_parent(@parent_b)

          @child_of_b.define_parent(@parent_a)
          @child_of_b.undefine_parent(@parent_a)

          @child_of_a_and_b = FactoryGirl.create(:blog_category)
          @child_of_a_and_b.define_parent(@parent_a)
          @child_of_a_and_b.define_parent(@parent_b)

          @grand_child_of_a = FactoryGirl.create(:blog_category)
          @grand_child_of_a.define_parent(@child_of_a)
        end

        describe '#parents' do
          it 'finds parents multi-parent child' do
            expect(@child_of_a_and_b.parents.to_set).to eq([@parent_a, @parent_b].to_set)
          end

          it 'finds parents of single-parent child' do
            expect(@child_of_a.parents.to_set).to eq([@parent_a].to_set)
          end
        end

        describe '#children' do
          it 'finds children of multi-child parent' do
            expect(@parent_a.children.to_set).to eq([@child_of_a, @child_of_a_and_b].to_set)
          end
        end
      end

      describe "validations" do
        it "requires title" do
          FactoryGirl.build(:blog_category, :title => "").should_not be_valid
        end

        it "won't allow duplicate titles" do
          FactoryGirl.build(:blog_category, :title => category.title).should_not be_valid
        end
      end

      describe "blog posts association" do
        it "has a posts attribute" do
          category.should respond_to(:posts)
        end

        it "returns posts by published_at date in descending order" do
          first_post = category.posts.create!({ :title => "Breaking News: Joe Sak is hot stuff you guys!!",
                                                :body => "True story.",
                                                :published_at => Time.now.yesterday,
                                                :author => refinery_user })

          latest_post = category.posts.create!({ :title => "parndt is p. okay",
                                                 :body => "For a Kiwi.",
                                                 :published_at => Time.now,
                                                 :author => refinery_user })

          category.posts.newest_first.first.should == latest_post
        end

      end

      describe "#post_count" do
        it "returns post count in category" do
          2.times do
            category.posts << FactoryGirl.create(:blog_post)
          end
          category.post_count.should == 2
        end
      end
    end
  end
end
