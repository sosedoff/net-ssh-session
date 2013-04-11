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
    before { session.stub(:run).with("uname").and_return(fake_run("uname", "Linux")) }

    it 'runs a command based on missing method name' do
      expect(session.uname.output).to eq "Linux"
    end
  end

  describe '#run' do
    context 'when session timeout is set' do
      let(:process) do
        proc { sleep 5 }
      end

      let(:session) do
        Net::SSH::Session.new('host', 'user', 'password', :timeout => 1)
      end

      before do
        session.stub_chain(:shell, :execute).with('foo') { process.call }
      end

      it 'raises error if operation timed out' do
        expect { session.run('foo') }.to raise_error Timeout::Error
      end
    end
  end
end