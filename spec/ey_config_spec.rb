require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'tempfile'

describe EY::Config do
  
  SAMPLE_DATA = {
    :some_app =>  {:foo => 1, :bar => 2},
    :another_app => {:haz => 'cheezburger', :bath => 'DO NOT WANT'}
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
        EY::Config.get.should have_key(:some_app)
        EY::Config.get[:some_app][:foo].should == 1
      end

      it "returns nil for nonexistent keys" do
        EY::Config.get.should_not have_key(:robot_overlord)
        EY::Config.get[:some_app][:baz].should be_nil
      end
    end

    context "which does not have the format we expect" do
      after(:each) do
        @data.unlink
      end

      it "emits a warning" do
        first_config = write_out_deploy_yml("this is crap data which is not yaml")
        EY::Config.config_path = first_config.path
        lambda{
          EY::Config.init
        }.should raise_error(/expected (.*) contain a hash of hashes/i)
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