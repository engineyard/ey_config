require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'tempfile'

describe "integrations" do

  def with_clean_env
    old_vals = {}
    ENV.keys.each do |k|
      if k.to_s.match(/BUNDLE/)
        old_vals[k] = ENV[k]
        ENV[k] = nil
      end
    end
    yield
  ensure
    old_vals.each do |k, v|
      ENV[k] = v
    end
  end

  it "works for deployonly" do
    path = File.expand_path('integrations/deployonly', File.dirname(__FILE__))
    with_clean_env do
      `cd #{path} && bundle`
      `cd #{path} && bundle exec ruby test.rb`.should eq "DEPLOYONLYBAR\n"
    end
  end

  it "works for localonly" do
    path = File.expand_path('integrations/localonly', File.dirname(__FILE__))
    with_clean_env do
      `cd #{path} && bundle`
      `cd #{path} && bundle exec ruby test.rb`.should eq "LOCALONLYBAR\n"
    end
  end

  it "loads the deploy when both exist" do
    path = File.expand_path('integrations/both', File.dirname(__FILE__))
    with_clean_env do
      `cd #{path} && bundle`
      `cd #{path} && bundle exec ruby test.rb`.should eq "DEPLOYBOTHBAR\n"
    end
  end

end