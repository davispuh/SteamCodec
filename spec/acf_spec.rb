require 'spec_helper'

describe SteamCodec::ACF do

    let(:appCacheFile) { <<-EOS
        "AppState"
        {
            "appid"             "207930"
            "Universe"          "1"
            "StateFlags"        "4"
            "installdir"        "sacred_citadel"
            "LastUpdated"       "1377100000"
            "UpdateResult"      "0"
            "SizeOnDisk"        "1193761500"
            "buildid"           "60250"
            "LastOwner"         "0"
            "BytesToDownload"   "0"
            "BytesDownloaded"   "0"
            "FullValidateOnNextUpdate"    "1"
            "UserConfig"
            {
                "name"          "Sacred Citadel"
                "gameid"        "207930"
                "installed"     "1"
                "appinstalldir" "C:\\Steam\\steamapps\\common\\sacred_citadel"
                "language"      "english"
                "BetaKey"       "public"
            }
            "MountedDepots"
            {
                "228982"        "6039653574073929574"
                "228983"        "4721092052804263356"
            }
            "SharedDepots"
            {
                "228984"        "228980"
            }
            "checkguid"
            {
                "0"     "Bin\\some.exe"
                "1"     "Bin\\another.exe"
            }
            "InstallScripts"
            {
                "0"     "_CommonRedist\\vcredist\\2008\\installscript.vdf"
                "1"     "_CommonRedist\\vcredist\\2010\\installscript.vdf"
            }
        }
        EOS
    }

    describe '.loadFromFile' do
        it 'should successfully load from file' do
            StringIO.open(appCacheFile) do |file|
                SteamCodec::ACF::loadFromFile(file).should be_an_instance_of SteamCodec::ACF
            end
        end
    end

    describe '.load' do
        it 'should successfully load' do
            SteamCodec::ACF::load(appCacheFile).should be_an_instance_of SteamCodec::ACF
        end
    end

    describe '.new' do
        it 'should initialize new instance with empty fields' do
            SteamCodec::ACF.new.AppID.should be_nil
        end
    end

    describe '#InstallDir' do
        it 'should return value' do
            SteamCodec::ACF::load(appCacheFile).InstallDir.should eq("sacred_citadel")
        end
    end

    describe SteamCodec::ACF::UserConfig do
        describe '.new' do
            it 'should initialize new instance with empty fields' do
                SteamCodec::ACF::UserConfig.new.Name.should be_nil
            end

            it 'should initialize new instance with provided fields' do
                SteamCodec::ACF::UserConfig.new(SteamCodec::KeyValues[{"Name" => "Game"}]).Name.should eq("Game")
            end
        end
    end

    describe SteamCodec::ACF::MountedDepots do
        let(:depots) { {"228982" => "6039653574073929574"} }
        describe '.new' do
            it 'should initialize new instance with empty fields' do
                SteamCodec::ACF::MountedDepots.new.depots.should eq([])
                SteamCodec::ACF::MountedDepots.new.manifests.should eq([])
            end

            it 'should initialize new instance with provided fields' do
                SteamCodec::ACF::MountedDepots.new(depots).depots.should eq([228982])
                SteamCodec::ACF::MountedDepots.new(depots).manifests.should eq(["6039653574073929574"])
            end
        end

        describe '#getManifest' do
            it 'should return manifest' do
                SteamCodec::ACF::MountedDepots.new(depots).getManifest(228982).should eq("6039653574073929574")
            end
        end

        describe '#getDepot' do
            it 'should return depot' do
                SteamCodec::ACF::MountedDepots.new(depots).getDepot("6039653574073929574").should eq(228982)
            end
        end
    end

    describe SteamCodec::ACF::SharedDepots do
        let(:depots) { {"228984" => "228980"} }
        describe '.new' do
            it 'should initialize new instance with empty fields' do
                SteamCodec::ACF::SharedDepots.new.depots.should eq([])
            end

            it 'should initialize new instance with provided fields' do
                SteamCodec::ACF::SharedDepots.new(depots).depots.should eq([228984])
                SteamCodec::ACF::SharedDepots.new(depots).getDepot(228984).should eq(228980)
            end
        end

        describe '#getDepot' do
            it 'should return depot' do
                SteamCodec::ACF::SharedDepots.new(depots).getDepot(228984).should eq(228980)
            end
        end
    end

end
