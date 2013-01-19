require 'spec_helper'

describe Net::SSH::Session do
  describe '#method_missing' do
    let(:session) { Net::SSH::Session.new('host', 'user', 'password') }

    it 'runs a command based on missing method name' do
      session.stub(:run).with("uname").and_return(fake_run("uname", "Linux"))
      session.uname.output.should eq("Linux")
    end
  end
end