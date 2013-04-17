require 'spec_helper'

describe 'RDoc Examples' do

  describe 'README.rdoc' do

    it 'should obey basic context use' do
      map = {
        sum: ->(c){ c[:x] + c[:y] },
          x: ->(c){ c.locals[:x] },
          y: ->(c){ c.locals[:y] }
      }

      sum = Reduxco::Context.new(map).run(:sum, x:3, y:5)
      sum.should == 8
    end

    it 'should override/shadow' do
      map1 = {
        message: ->(c){ 'Hello From Map 1' }
      }

      map2 = {
        message: ->(c){ 'Hello From Map 2' }
      }

      msg = Reduxco::Context.new(map1, map2).run(:message, {})
      msg.should == 'Hello From Map 2'
    end

    it 'should super' do
      map1 = {
        message: ->(c){ 'Hello From Map 1' }
      }

      map2 = {
        message: ->(c){ c.super + ' and Hello From Map 2' }
      }

      msg = Reduxco::Context.new(map1, map2).run(:message, {})
      msg.should == 'Hello From Map 1 and Hello From Map 2'
    end

  end

end