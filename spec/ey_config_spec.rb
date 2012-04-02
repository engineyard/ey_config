require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'tempfile'

describe EY::Config do

  SAMPLE_DATA = {
    'some_app' =>  {'foo' => 1, 'bar' => 2},
    'another_app' => {'haz' => 'cheezburger', 'bath' => 'DO NOT WANT'}
  }

  def write_out_deploy_yml(str)
    @data = Tempfile.new("deploy.yml")
    @data.write(str)
    @data.close
    @data
  end

  def set_config_paths(first_config, second_config)
    EY::Config.config_path = first_config.path
  end

  context "with a config file present" do
    context "which is valid" do
      before(:each) do
        first_config = write_out_deploy_yml(YAML.dump(SAMPLE_DATA))
        EY::Config.config_path = first_config.path
        EY::Config.init
      end

      after(:each) do
        @data.unlink
      end

      it "reads from config file" do
        EY::Config.get(:some_app, "foo").should == 1
        EY::Config.warnings.should be_empty
      end

      it "prevents accidentally modifying the config" do
        lambda{ EY::Config.get(:some_app)["foo"] = "BADDATA" }.should raise_error TypeError
      end

      it "raises and warns for nonexistent keys" do
        lambda { EY::Config.get(:some_app, "baz") }.should raise_error ArgumentError
        EY::Config.warnings.detect{|w| w.match(/No config found/i)}.should_not be_nil
      end

    end

    context "#detected_a_dev_environment" do
      it "warns the user to run ey_config_local if config not present" do
        lambda{ EY::Config.get(:no_key_under_me, "baz") }.should raise_error ArgumentError
        EY::Config.warnings.detect{|w| w.match(/To generate a config file for local development, run the following/i)}.should_not be_nil
      end

      it "raises on access to non-existant key, but doesn't tell you to generate a file if one exists" do
        first_config = write_out_deploy_yml(YAML.dump(SAMPLE_DATA))
        EY::Config.config_path = first_config.path
        EY::Config.init
        lambda { EY::Config.get(:no_key_under_me, "baz") }.should raise_error ArgumentError
        EY::Config.warnings.detect{|w| w.match(/To generate a config file for local development, run the following/i)}.should be_nil
      end

      context "in production rails env" do
        before do
          @old_val = ENV["RAILS_ENV"]
          ENV["RAILS_ENV"] = "production"
        end
        after do
          ENV["RAILS_ENV"] = @old_val
        end

        it "displays message about service missing" do
          lambda{ EY::Config.get(:no_key_under_me, "baz") }.should raise_error ArgumentError
          EY::Config.warnings.detect{|w| w.match(/Activate the services that provides/i)}.should_not be_nil
        end
      end
    end

    context "which does not have the format we expect" do
      after(:each) do
        @data.unlink
      end

      it "emits a warning" do
        first_config = write_out_deploy_yml("this is crap data which is not yaml")
        EY::Config.config_path = first_config.path
        EY::Config.get
        EY::Config.warnings.detect{|w| w.match(/expected (.*) contain a hash of hashes/i)}.should_not be_nil
      end

    end
  end

  it "raises an error if deploy.yml is missing" do
    expect { EY::Config.init }.to raise_error(/Expected to find EY::Config YAML file at one of/)
  end

  it "raises an error if deploy.yml has bad permissions" do
    first_config = write_out_deploy_yml(YAML.dump(SAMPLE_DATA))
    EY::Config.config_path = first_config.path
    File.chmod(0333, first_config.path)

    expect { EY::Config.init }.to raise_error    
  end
end