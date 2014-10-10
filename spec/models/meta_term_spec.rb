require 'spec_helper'

describe MetaTerm do
  describe ".create" do
    it "should not accept an empty term" do
      meta_term = MetaTerm.create(term: '')
      expect(meta_term.persisted?).to be false
    end

    it "removes all leading & tailing whitespaces from a term" do
      meta_term = MetaTerm.create(term: ' amazing meta term   ')
      expect(meta_term.term).to eq('amazing meta term')
    end

    it "accepts Symbol as a term" do
      expect{ MetaTerm.create(term: :Red) }.to_not raise_error
    end
  end
end
