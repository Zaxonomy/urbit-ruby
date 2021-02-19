require "urbit/config"

describe Urbit::Config do
  context 'default settings' do
    let(:instance) { described_class.new }

    it "exposes the ship code" do
      expect(instance.code).to eq(Urbit::Config::DEFAULT_CODE)
    end

    it "exposes the ship host" do
      expect(instance.host).to eq(Urbit::Config::DEFAULT_HOST)
    end

    it "exposes the ship port" do
      expect(instance.port).to eq(Urbit::Config::DEFAULT_PORT)
    end

    it "exposes the ship name" do
      expect(instance.name).to eq(Urbit::Config::DEFAULT_NAME)
    end
  end

  context 'custom settings from constructor' do
    let(:instance) { described_class.new(code: 'test-code', host: 'example.com', name: 'test-name', port: '8080') }

    it "exposes the custom ship code" do
      expect(instance.code).to eq('test-code')
    end

    it "exposes the custom ship host" do
      expect(instance.host).to eq('example.com')
    end

    it "exposes the custom ship name" do
      expect(instance.name).to eq('test-name')
    end

    it "exposes the custom ship port" do
      expect(instance.port).to eq('8080')
    end
  end

  context 'custom settings from config yaml file' do
    let(:instance) { described_class.new(config_file: 'spec/test_config.yml') }

    it "exposes the custom ship code" do
      expect(instance.code).to eq('foobar')
    end

    it "exposes the ship name" do
      expect(instance.name).to eq('~fofbar-hacker')
    end
  end
end
