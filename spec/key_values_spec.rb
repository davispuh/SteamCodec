# encoding: UTF-8
require 'spec_helper'

describe SteamCodec::KeyValues do

    let(:tokenKey) { 'TokenKey123' }
    let(:tokenValue) { 'Token+Value4567' }
    let(:tokenKeyQuoted) { "\"#{tokenKey}\"" }
    let(:tokenValueQuoted) { "\"#{tokenValue}\"" }

    let(:jsonSample1a) { "#{tokenKeyQuoted} #{tokenValueQuoted}" }
    let(:jsonSample1b) { "#{tokenKeyQuoted}\n{\t#{tokenKeyQuoted}\t#{tokenValueQuoted}\n}" }

    let(:jsonSample2a) { "#{tokenKeyQuoted} #{tokenValueQuoted}\n#{tokenKeyQuoted}\t#{tokenValueQuoted}" }
    let(:jsonSample2b) { "#{tokenKeyQuoted}\t{}\n#{tokenKeyQuoted} #{tokenValueQuoted}" }

    let(:jsonSample3a) { '"Ke\\ty\\\\is" "Val\\nue\\\\\\""' }
    let(:jsonSample3b) { '"Ke\\\\ty\\is\\\\" "te\\\\s\\\\n\\\\v\\"\\\\"' }

    let(:jsonSample4a) { "#{tokenKey} #{tokenValue}" }
    let(:jsonSample4b) { "#{tokenKey}\n{\t#{tokenKey}\t#{tokenValue}\n}" }

    let(:jsonSample5a) { 'abc "lol this {weird string}"' }
    let(:jsonSample5b) { "\"\\\"really weird\\\"\n{\n\\\"string\\\" \\\"this is\\\"\n}\"\n{\n\"string\" \"this is\"\n}" }

    let(:jsonSample6a) { "#{tokenKeyQuoted}\\\\this should be ignored\n{\t#{tokenKeyQuoted}\t#{tokenValueQuoted}\n}" }

    let(:jsonSample7a) { "#base <blah.vdf>\n#{tokenKey}\n{\t#{tokenKey}\t#{tokenValue}\n}" }
    let(:jsonSample7b) { "#include <blah.vdf>\n#{tokenKey}\n{\t#{tokenKey}\t#{tokenValue}\n}" }

    let(:keyValueData) { <<-EOS
        "AppState"
        {
            "appid"     "320"
            "Universe"  "1"
            "SomeArrayValue_1"  "4"
            "SomeArrayValue_2"  "3"
            "SomeArrayValue_3"  "2"
        }
        EOS
    }
    let(:keyValueResult) {
        { "appid" => "320", "Universe" => "1", "SomeArrayValue_1" => "4", "SomeArrayValue_2" => "3", "SomeArrayValue_3" => "2" }
    }

    describe SteamCodec::KeyValues::Parser do

        describe '.isEscaped' do
            it 'empty string should not be escaped' do
                SteamCodec::KeyValues::Parser::isEscaped('', 0).should be_false
            end

            it 'should be escaped' do
                SteamCodec::KeyValues::Parser::isEscaped('\\"', 1).should be_true
                SteamCodec::KeyValues::Parser::isEscaped('\\\\\\"', 3).should be_true
                SteamCodec::KeyValues::Parser::isEscaped('trol\\lol\\lol\\"trrr', 13).should be_true
            end

            it 'should not be escaped' do
                SteamCodec::KeyValues::Parser::isEscaped('\\\\"', 2).should be_false
                SteamCodec::KeyValues::Parser::isEscaped('\\\\\\\\"', 4).should be_false
                SteamCodec::KeyValues::Parser::isEscaped('trol\\lol\\lol\\\\"trrr', 14).should be_false
            end

        end

        describe '.toJSON' do
            it 'should convert correctly empty data' do
                SteamCodec::KeyValues::Parser::toJSON('').should eq('{}')
            end

            it 'should raise exception on invalid data' do
                expect { SteamCodec::KeyValues::Parser::toJSON(nil) }.to raise_error(ArgumentError)
                expect { SteamCodec::KeyValues::Parser::toJSON({})  }.to raise_error(ArgumentError)
            end

            it 'should add colon after tokens' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample1a).should eq("{#{tokenKeyQuoted}: #{tokenValueQuoted}}")
                SteamCodec::KeyValues::Parser::toJSON(jsonSample1b).should eq("{#{tokenKeyQuoted}:\n{\t#{tokenKeyQuoted}:\t#{tokenValueQuoted}\n}}")
            end

            it 'should add comma after entries' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample2a).should eq("{#{tokenKeyQuoted}: #{tokenValueQuoted},\n#{tokenKeyQuoted}:\t#{tokenValueQuoted}}")
                SteamCodec::KeyValues::Parser::toJSON(jsonSample2b).should eq("{#{tokenKeyQuoted}:\t{},\n#{tokenKeyQuoted}: #{tokenValueQuoted}}")
            end

            it 'should regard slashes' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample3a).should eq('{"Ke\\ty\\\\is": "Val\\nue\\\\\\""}')
                SteamCodec::KeyValues::Parser::toJSON(jsonSample3b).should eq('{"Ke\\\\ty\\is\\\\": "te\\\\s\\\\n\\\\v\\"\\\\"}')
            end

            it 'should parse keys and values without quotes' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample4a).should eq("{#{tokenKeyQuoted}: #{tokenValueQuoted}}")
                SteamCodec::KeyValues::Parser::toJSON(jsonSample4b).should eq("{#{tokenKeyQuoted}:\n{\t#{tokenKeyQuoted}:\t#{tokenValueQuoted}\n}}")
            end

            it 'should parse special cases' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample5a).should eq("{\"abc\": \"lol this {weird string}\"}")
                SteamCodec::KeyValues::Parser::toJSON(jsonSample5b).should eq("{\"\\\"really weird\\\"\\n{\\n\\\"string\\\" \\\"this is\\\"\\n}\":\n{\n\"string\": \"this is\"\n}}")
            end

            it 'should ignore comments' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample6a).should eq("{#{tokenKeyQuoted}:\n{\t#{tokenKeyQuoted}:\t#{tokenValueQuoted}\n}}")
            end

            it 'should ignore #include and #base' do
                SteamCodec::KeyValues::Parser::toJSON(jsonSample7a).should eq("{\n#{tokenKeyQuoted}:\n{\t#{tokenKeyQuoted}:\t#{tokenValueQuoted}\n}}")
                SteamCodec::KeyValues::Parser::toJSON(jsonSample7b).should eq("{\n#{tokenKeyQuoted}:\n{\t#{tokenKeyQuoted}:\t#{tokenValueQuoted}\n}}")
            end
        end
    end

    describe '.loadFromJSON' do
        it 'should return nil for invalid json' do
            SteamCodec::KeyValues::loadFromJSON('invalid :P').should be_nil
        end
    end

    describe '.load' do
        it 'should load correctly empty data' do
            SteamCodec::KeyValues::load('').should eq({})
        end

        it 'should raise exception on invalid data' do
            expect { SteamCodec::KeyValues::load(nil) }.to raise_error(ArgumentError)
            expect { SteamCodec::KeyValues::load({})  }.to raise_error(ArgumentError)
        end

        it 'should load correctly various representations' do
            SteamCodec::KeyValues::load(jsonSample1a).should eq({ tokenKey => tokenValue })
            SteamCodec::KeyValues::load(jsonSample1b).should eq({ tokenKey => { tokenKey => tokenValue } })
            SteamCodec::KeyValues::load(jsonSample2a).should eq({ tokenKey => tokenValue })
            SteamCodec::KeyValues::load(jsonSample2b).should eq({ tokenKey => tokenValue })
            SteamCodec::KeyValues::load(jsonSample3a).should eq({"Ke\ty\\is" => "Val\nue\\\""})
            SteamCodec::KeyValues::load(jsonSample3b).should eq({'Ke\\tyis\\' => "te\\s\\n\\v\"\\"})
            SteamCodec::KeyValues::load(jsonSample4a).should eq({ tokenKey => tokenValue })
            SteamCodec::KeyValues::load(jsonSample4b).should eq({ tokenKey => { tokenKey => tokenValue } })
            SteamCodec::KeyValues::load(jsonSample5a).should eq({"abc" => "lol this {weird string}"})
            SteamCodec::KeyValues::load(jsonSample5b).should eq({"\"really weird\"\n{\n\"string\" \"this is\"\n}" => {"string" => "this is"}})
            SteamCodec::KeyValues::load(jsonSample6a).should eq({ tokenKey => { tokenKey => tokenValue } })
            SteamCodec::KeyValues::load(jsonSample7a).should eq({ tokenKey => { tokenKey => tokenValue } })
            SteamCodec::KeyValues::load(jsonSample7b).should eq({ tokenKey => { tokenKey => tokenValue } })
        end
    end

    describe '.loadFromFile' do
        it 'should raise exception if not file' do
            expect { SteamCodec::KeyValues::loadFromFile("blah") }.to raise_error(ArgumentError)
        end

        it 'should succesfully load from file' do
            StringIO.open(keyValueData) do |file|
                SteamCodec::KeyValues::loadFromFile(file).should eq({ "AppState" => keyValueResult })
            end
        end

        it 'should be KeyValues instance' do
            StringIO.open(keyValueData) do |file|
                SteamCodec::KeyValues::loadFromFile(file).should be_an_instance_of SteamCodec::KeyValues
            end
        end
    end

    describe '#get' do
        let(:keyValues) { SteamCodec::KeyValues::load(keyValueData) }

        it 'should get field value' do
            keyValues.get('AppState/AppID').should eq("320")
        end

        it 'should get field value even with slashes at start and end' do
            keyValues.get('/AppState/AppID/').should eq("320")
        end

        it 'should be nil if field doesn\'t exist' do
            keyValues.get('AppState/Something').should be_nil
        end
    end

    describe '#asArray' do
        let(:keyValues) { SteamCodec::KeyValues::load(keyValueData) }

        it 'should load fields as array' do
            keyValues.AppState.asArray('SomeArrayValue').should eq(['4','3','2'])
        end
    end

    describe 'access any field' do
        let(:keyValues) { SteamCodec::KeyValues::load(keyValueData) }

        it 'should be able to access AppState' do
            keyValues.AppState.should eq(keyValueResult)
        end

        it 'should be able to read AppID' do
            keyValues.AppState.AppID.should eq("320")
        end

        it 'should check if field exists' do
            keyValues.AppState.has_key?(:AppID).should be_true
            keyValues.AppState.has_key?(:UserConfig).should be_false
            keyValues.respond_to?(:appstate).should be_true
            keyValues.respond_to?(:nope).should be_false
        end

        it 'should raise exception for non-existent field' do
            expect { keyValues.AppState.UserConfig }.to raise_error(NoMethodError)
        end
    end

end
