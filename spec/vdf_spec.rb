# encoding: UTF-8
require 'spec_helper'

describe SteamCodec::VDF do

    let(:valveDataFile) { <<-EOS
        "InstallScript"
        {
            "Registry"
            {
                "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Activision\\\\Singularity"
                {
                    "string"
                    {
                        "EXEString"     "%INSTALLDIR%\\\\Binaries\\\\Singularity.exe"
                        "InstallPath"       "%INSTALLDIR%"
                        "IntVersion"        "35.0"
                        "Version"       "1.0"
                        "english"
                        {
                            "Language"      "1033"
                            "LanguageCode"      "ENU"
                            "Localization"      "ENU"
                        }
                        "french"
                        {
                            "Language"      "1036"
                            "LanguageCode"      "FRA"
                            "Localization"      "FRA"
                        }
                        "german"
                        {
                            "Language"      "1031"
                            "LanguageCode"      "DEU"
                            "Localization"      "DEU"
                        }
                        "italian"
                        {
                            "Language"      "1040"
                            "LanguageCode"      "ITA"
                            "Localization"      "ITA"
                        }
                        "spanish"
                        {
                            "Language"      "1034"
                            "LanguageCode"      "ESP"
                            "Localization"      "ESP"
                        }
                    }
                    "dword"
                    {
                        "english"
                        {
                            "GameLanguage"      "0"
                        }
                        "french"
                        {
                            "GameLanguage"      "1"
                        }
                        "german"
                        {
                            "GameLanguage"      "0"
                        }
                        "italian"
                        {
                            "GameLanguage"      "2"
                        }
                        "spanish"
                        {
                            "GameLanguage"      "4"
                        }
                    }
                }
            }
            "Run Process"
            {
                "DirectX"
                {
                    "process 1"     "%INSTALLDIR%\\\\redist\\\\DirectX\\\\DXSETUP.exe"
                    "command 1"     "/silent"
                    "Description"       "DirectX Installation"
                    "NoCleanUp"     "1"
                }
                "VC++"
                {
                    "process 1"     "%INSTALLDIR%\\\\redist\\\\vcredist_x86.exe"
                    "command 1"     "/q:a"
                    "process 2"     "%INSTALLDIR%\\\\redist\\\\vcredist_x86_2005.exe"
                    "command 2"     "/q:a"
                    "Description"       "VC++ Redist Installation"
                    "NoCleanUp"     "1"
                }
                "PhysX Version"
                {
                    "HasRunKey"     "HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\AGEIA Technologies"
                    "process 1"     "%INSTALLDIR%\\\\redist\\\\PhysX_9.09.1112_SystemSoftware.exe"
                    "command 1"     "/quiet"
                    "NoCleanUp"     "1"
                    "MinimumHasRunValue"        "9091112"
                }
            }
        }
        "kvsignatures"
        {
            "InstallScript"     "973f7d89125ad1fc782a970deb175cf84d48c49581ba3a76fedfefa8116a6d500459fd8df99285850ef99d767a83c2de009de5951607930557c937439908fbc1cc8156e963320c54080e7a1a634ccbf2e5f58883bd11bb2ed10c07be5af8e482d9a17d22a6fe40980124e5fced1c241f158b460941984c41432eeeb2aeaa01b1"
        }        
        EOS
    }

    describe '.loadFromFile' do
        it 'should successfully load from file' do
            StringIO.open(valveDataFile) do |file|
                SteamCodec::VDF::loadFromFile(file).should be_an_instance_of SteamCodec::VDF
            end
        end
    end

    describe '.load' do
        it 'should successfully load' do
            SteamCodec::VDF::load(valveDataFile).should be_an_instance_of SteamCodec::VDF
        end
    end

    describe 'key field' do
        it 'should return value' do
            SteamCodec::VDF::load(valveDataFile).InstallScript.Registry.should be_an_instance_of SteamCodec::KeyValues
        end
    end

    describe '#isSignaturesValid?' do
        it 'should check if signature is valid' do
            SteamCodec::VDF.new.isSignaturesValid?(nil).should be_true
            SteamCodec::VDF::load(valveDataFile).isSignaturesValid?(nil).should be_false
        end
    end

end
