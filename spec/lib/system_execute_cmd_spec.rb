require 'spec_helper'

describe 'System' do

  describe 'execute_cmd!' do

    it 'returns output on successful call' do
      string = 'HELLO'
      output = ::System.execute_cmd!("printf #{string}")
      expect(output).to eq string
    end

    it 'fails on invalid command' do
      expect do
        ::System.execute_cmd!('cat /dev/matrix/humans/neo >> /dev/reality')
      end.to raise_error
    end

  end

end
