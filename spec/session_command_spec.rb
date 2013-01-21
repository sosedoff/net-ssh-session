require 'spec_helper'

describe Net::SSH::SessionCommand do
  describe '#initialize' do
    it 'assigns attributes' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '128', 1.5)

      cmd.command.should be_a String
      cmd.output.should be_a String
      cmd.exit_code.should be_a Fixnum
      cmd.duration.should be_a Float
    end

    it 'sets exit code to 1 on invalid value' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', 'ohai')
      cmd.exit_code.should eq(1)
    end
  end

  describe '#success?' do
    it 'returns true for successful exit codes' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '0')
      cmd.success?.should be_true
    end

    it 'returns false for failed exit codes' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '1')
      cmd.success?.should be_false

      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '128')
      cmd.success?.should be_false
    end
  end

  describe '#failure?' do
    it 'returns true for non-zero exit codes' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '1')
      cmd.failure?.should be_true

      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '128')
      cmd.failure?.should be_true
    end

    it 'returns false for successful exit codes' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '0')
      cmd.failure?.should be_false
    end

    it 'has a :error? alias method' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '0')
      cmd.should respond_to :error?
    end
  end

  describe '#to_s' do
    it 'returns command string representation' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '0', 1.234)
      cmd.to_s.should eq("[cmd] => 0, 6 bytes, 1.234 seconds")
    end
  end

  describe '#to_hash' do
    it 'returns command hash representation' do
      cmd = Net::SSH::SessionCommand.new('cmd', 'output', '0', 1.234)
      hash = cmd.to_hash

      hash.should include 'command', 'output', 'exit_code'
      hash.should include 'start_time', 'finish_time', 'duration'
    end
  end
end