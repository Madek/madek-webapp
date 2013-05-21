require 'spec_helper'

describe ZHDK::Sort do

    describe "nested_sort" do
    
    it "should sort plain arrays" do
      expect(ZHDK::Sort.nested_sort([5,3,4])).to eq([3,4,5])
    end

    it "should sort nested arrays" do
      expect(ZHDK::Sort.nested_sort([[5,4],[2,3]])).to eq([[2,3],[4,5]])
    end

    it "should sort hashes" do
      expect(ZHDK::Sort.nested_sort({x: 5, a: 10}).to_a).to eq([[:a,10],[:x,5]])
    end

    it "should sort arrays nested in hashes and the hashes to" do
      expect(ZHDK::Sort.nested_sort({x: 5, a: 10, b: [7,1] }).to_a).to eq( [[:a, 10], [:b, [1, 7]], [:x, 5]])
    end

  end

end

