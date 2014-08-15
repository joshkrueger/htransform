require 'spec_helper'
require 'date'

describe HTransform do
  describe "convert" do
    context "using the nested block" do

      it "defaults to output nesting" do
        class TestHTransform < HTransform
          transform do
            nested :key => :foo_nest do
              input "foo" => :foo
            end
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { :foo_nest => { :foo => "bar" } }

        result = TestHTransform.convert(input_hash)

        result.should == desired_hash        
      end

      it "uses output nested when specified" do
        class TestHTransform < HTransform
          transform do
            nested :type => "output", :key => :foo_nest do
              input "foo" => :foo
            end
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { :foo_nest => { :foo => "bar" } }
        
        result = TestHTransform.convert(input_hash)
        
        result.should == desired_hash
      end

      it "uses input nesting when specified" do
        class TestHTransform < HTransform
          transform do
            nested :type => "input", :key => :nested_data do
              input "foo" => :foo
            end
          end
        end

        input_hash = { :nested_data => { "foo" => "bar" } }
        desired_hash = { :foo => "bar" }
        
        result = TestHTransform.convert(input_hash)
        
        result.should == desired_hash
      end

      it "can nest multiple nested blocks of different types" do
        class TestHTransform < HTransform
          transform do
            nested :type => "input", :key => :nested_input do
              input :foo_nest => :foo
              input :bar_nest => :bar

              nested :type => "input", :key => :more_nesting do
                nested :type => "output", :key => :nested do
                  input :foobar => :foo_bar
                end
              end
            end

            nested :key => :animal_sounds do
              passthrough :cat, :dog
            end
          end
        end

        input_hash = { :nested_input => { :foo_nest => "foo!", :bar_nest => "bar!", :more_nesting => { :foobar => "meh"} },
                        :cat => "meow!", :dog => "woof!" }

        desired_hash = { :foo => "foo!", :bar => "bar!", :nested => { :foo_bar => "meh"} , :animal_sounds => { :cat => "meow!", :dog => "woof!" } }
        
        result = TestHTransform.convert(input_hash)
        
        result.should == desired_hash
      end

      it "can use the shorthand method and default to output nesting" do
        class TestHTransform < HTransform
          transform do
            nested :out_nest do
              input "foo" => :foo
            end
          end
        end

        input_hash = { "foo" => "bar" }
        desired_hash = { :out_nest => { :foo => "bar" } }

        result = TestHTransform.convert(input_hash)

        result.should == desired_hash
      end

    end
  end
end
