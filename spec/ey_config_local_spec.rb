require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'tempfile'

describe EY::Config::Local do
  before :all do
    @original_path = Dir.pwd
  end

  before do
    Dir.chdir Dir.mktmpdir
  end

  after do
    Dir.chdir @original_path
  end

  describe 'when no ey_services_config_local.yml exists' do
    before do
      EY::Config::Local.generate('sample-service', 'SOMEKEY')
    end

    it 'should create ey_services_config_local.yml' do
      File.exist?(EY::Config::Local.config_path).should be_true
    end

    it 'should add the keys passed from the command line' do
      YAML.load_file(EY::Config::Local.config_path)['sample-service']['SOMEKEY'].should == 'SAMPLE'
    end
  end

  describe 'when a good ey_services_config_local.yml exists' do
    before do
      FileUtils.mkdir('config')
      File.open(EY::Config::Local.config_path, 'w') do |f|
        f.print YAML.dump({ 'a' => 'b' })
      end
      EY::Config::Local.generate('sample-service', 'SOMEKEY')
    end

    it 'should add the keys passed from the command line' do
      YAML.load_file(EY::Config::Local.config_path)['sample-service']['SOMEKEY'].should == 'SAMPLE'
      EY::Config.warnings.should be_empty
    end

    it 'should leave the existing parameters intact' do
      YAML.load_file(EY::Config::Local.config_path)['a'].should == 'b'
      EY::Config.warnings.should be_empty
    end
  end

  describe 'when a ey_services_config_local.yml exists with unparseable YAML' do
    before do
      FileUtils.mkdir('config')
      File.open(EY::Config::Local.config_path, 'w') do |f|
        '{etwet2et2e2t'
      end
      EY::Config::Local.generate('sample-service', 'nested_attr', 'VALUE')
    end

    it 'should add the keys passed from the command line' do
      YAML.load_file(EY::Config::Local.config_path)['sample-service']['nested_attr']['VALUE'].should == 'SAMPLE'
      EY::Config.warnings.should be_empty
    end

  end

  describe 'when a ey_services_config_local.yml exists with a config file containing a string instead of a hash' do
    before do
      FileUtils.mkdir('config')
      File.open(EY::Config::Local.config_path, 'w') do |f|
        YAML.dump('This is a string')
      end
      EY::Config::Local.generate('sample-service', 'nested_attr', 'VALUE')
    end

    it 'should add the keys passed from the command line' do
      YAML.load_file(EY::Config::Local.config_path)['sample-service']['nested_attr']['VALUE'].should == 'SAMPLE'
      EY::Config.warnings.should be_empty
    end
  end
end
