require 'spec_helper'

describe Net::SSH::Session do
  describe '#initialize' do
    context 'with :timeout option' do
      it 'raises error if timeout value is not numeric' do
        expect {
          Net::SSH::Session.new('host', 'user', 'password', :timeout => 'data')
        }.to raise_error ArgumentError, "Timeout value should be numeric"
      end

      it 'sets global session timeout value' do
        session = Net::SSH::Session.new('host', 'user', 'password', :timeout => 1)
        expect(session.timeout).to eq 1
      end
    end
  end 

  describe '#method_missing' do
    let(:session) { Net::SSH::Session.new('host', 'user', 'password') }

    it 'runs a command based on missing method name' do
      session.stub(:run).with("uname").and_return(fake_run("uname", "Linux"))
      session.uname.output.should eq("Linux")
    end
  end
end