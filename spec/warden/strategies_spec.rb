# encoding: utf-8
require 'spec_helper'

describe Warden::Strategies do
  it "should let me add a strategy via a block" do
    Warden::Strategies.add(:strategy1) do
      def authenticate!
        success("foo")
      end
    end
    Warden::Strategies[:strategy1].ancestors.should include(Warden::Strategies::Base)
  end

  it "should raise an error if I add a strategy via a block, that does not have an authenticate! method" do
    lambda do
      Warden::Strategies.add(:strategy2) do
      end
    end.should raise_error
  end

  it "should raise an error if I add a strategy that does not extend Warden::Strategies::Base" do
    non_base = Class.new do
      def authenticate!
      end
    end
    expect do
      Warden::Strategies.add(:strategy_non_base, non_base)
    end.to raise_error(/is not a Warden::Strategies::Base/)
  end

  it "should allow me to get access to a particular strategy" do
    Warden::Strategies.add(:strategy3) do
      def authenticate!; end
    end
    strategy = Warden::Strategies[:strategy3]
    strategy.should_not be_nil
    strategy.ancestors.should include(Warden::Strategies::Base)
  end

  it "should allow me to add a strategy with the required methods" do
    class MyStrategy < Warden::Strategies::Base
      def authenticate!; end
    end
    lambda do
      Warden::Strategies.add(:strategy4, MyStrategy)
    end.should_not raise_error
  end

  it "should not allow a strategy that does not have an authenticate! method" do
    class MyOtherStrategy
    end
    lambda do
      Warden::Strategies.add(:strategy5, MyOtherStrategy)
    end.should raise_error
  end

  it "should allow me to change a class when providing a block and class" do
    class MyStrategy < Warden::Strategies::Base
    end

    Warden::Strategies.add(:foo, MyStrategy) do
      remove_method :authenticate!
      def authenticate!; end
    end

    Warden::Strategies[:foo].ancestors.should include(MyStrategy)
  end

  it "should allow me to update a previously given strategy" do
    class MyStrategy < Warden::Strategies::Base
      remove_method :authenticate!
      def authenticate!; end
    end

    Warden::Strategies.add(:strategy6, MyStrategy)

    new_module = Module.new
    Warden::Strategies.update(:strategy6) do
      include new_module
    end

    Warden::Strategies[:strategy6].ancestors.should include(new_module)
  end

  it "should allow me to clear the strategies" do
    Warden::Strategies.add(:foobar) do
      def authenticate!
        :foo
      end
    end
    Warden::Strategies[:foobar].should_not be_nil
    Warden::Strategies.clear!
    Warden::Strategies[:foobar].should be_nil
  end
end
