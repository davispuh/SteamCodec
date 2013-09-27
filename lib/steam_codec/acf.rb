# encoding: UTF-8
module SteamCodec
    class ACF

        # More about AppID => https://developer.valvesoftware.com/wiki/Steam_Application_IDs
        attr_accessor :AppID
        attr_accessor :Universe
        attr_accessor :StateFlags
        attr_accessor :InstallDir
        attr_accessor :LastUpdated
        attr_accessor :UpdateResult
        attr_accessor :SizeOnDisk
        attr_accessor :BuildID
        attr_accessor :LastOwner
        attr_accessor :BytesToDownload
        attr_accessor :BytesDownloaded
        attr_accessor :FullValidateOnNextUpdate
        attr_reader :UserConfig
        attr_reader :MountedDepots
        attr_reader :SharedDepots
        attr_reader :CheckGuid
        attr_reader :InstallScripts
        def self.loadFromFile(file)
            acf = KeyValues::loadFromFile(file)
            return self.new(acf.AppState) if acf and acf.key?(:AppState)
            nil
        end

        def self.load(data)
            acf = KeyValues::load(data)
            return self.new(acf.AppState) if acf and acf.key?(:AppState)
            nil
        end

        def initialize(appState = nil)
            load(appState || KeyValues.new)
        end

        def load(appState)
            raise ArgumentError, "AppState must be instance of KeyValues" unless appState.is_a?(KeyValues)
            @AppState = appState
            @AppID = @AppState.AppID.to_i if @AppState.key?(:AppID)
            @Universe = @AppState.Universe.to_i if @AppState.key?(:Universe)
            @StateFlags = @AppState.StateFlags.to_i if @AppState.key?(:StateFlags)
            @InstallDir = @AppState.InstallDir if @AppState.key?(:InstallDir)
            @LastUpdated = @AppState.LastUpdated.to_i if @AppState.key?(:LastUpdated)
            @UpdateResult = @AppState.UpdateResult.to_i if @AppState.key?(:UpdateResult)
            @SizeOnDisk = @AppState.SizeOnDisk.to_i if @AppState.key?(:SizeOnDisk)
            @BuildID = @AppState.BuildID.to_i if @AppState.key?(:BuildID)
            @LastOwner = @AppState.LastOwner if @AppState.key?(:LastOwner)
            @BytesToDownload = @AppState.BytesToDownload.to_i if @AppState.key?(:BytesToDownload)
            @BytesDownloaded = @AppState.BytesDownloaded.to_i if @AppState.key?(:BytesDownloaded)
            @FullValidateOnNextUpdate = !@AppState.FullValidateOnNextUpdate.to_i.zero? if @AppState.key?(:FullValidateOnNextUpdate)
            userConfig = nil
            mountedDepots = {}
            sharedDepots = {}
            checkGuid = {}
            installScripts = {}
            userConfig = @AppState.UserConfig if @AppState.key?(:UserConfig)
            mountedDepots = @AppState.MountedDepots if @AppState.key?(:MountedDepots)
            sharedDepots = @AppState.SharedDepots if @AppState.key?(:sharedDepots)
            checkGuid = @AppState.CheckGuid if @AppState.key?(:CheckGuid)
            installScripts = @AppState.InstallScripts if @AppState.key?(:InstallScripts)
            @UserConfig = UserConfig.new(userConfig)
            @MountedDepots = MountedDepots.new(mountedDepots)
            @SharedDepots = SharedDepots.new(sharedDepots)
            @InstallScripts = InstallScripts.new(installScripts)
        end

        class UserConfig
            attr_accessor :Name
            attr_accessor :GameID
            attr_accessor :Installed
            attr_accessor :AppInstallDir
            attr_accessor :Language
            attr_accessor :BetaKey
            def initialize(userConfig = nil)
                load(userConfig || KeyValues.new)
            end

            def load(userConfig)
                raise ArgumentError, "UserConfig must be instance of KeyValues" unless userConfig.is_a?(KeyValues)
                @UserConfig = userConfig
                @Name = @UserConfig.name if @UserConfig.key?(:name)
                @GameID = @UserConfig.gameid.to_i if @UserConfig.key?(:gameid)
                @Installed = !@UserConfig.installdir.to_i.zero? if @UserConfig.key?(:installdir)
                @AppInstallDir = @UserConfig.appinstalldir if @UserConfig.key?(:appinstalldir)
                @Language = @UserConfig.language if @UserConfig.key?(:language)
                @BetaKey = @UserConfig.BetaKey if @UserConfig.key?(:BetaKey)
            end
        end

        class MountedDepots
            def initialize(mountedDepots = {})
                load(mountedDepots)
            end

            def load(mountedDepots)
                raise ArgumentError, "MountedDepots must be instance of Hash" unless mountedDepots.is_a?(Hash)
                @MountedDepots = {}
                mountedDepots.each do |depot, manifest|
                    @MountedDepots[depot.to_i] = manifest
                end
            end

            def depots
                @MountedDepots.keys
            end

            def manifests
                @MountedDepots.values
            end

            def getManifest(depotID)
                @MountedDepots.each do |depot, manifest|
                    return manifest if depot == depotID
                end
                nil
            end

            def getDepot(manifestID)
                @MountedDepots.each do |depot, manifest|
                    return depot if manifest == manifestID
                end
                nil
            end

            def set(depot, manifest)
                @MountedDepots[depot] = manifest
            end

            def remove(depot)
                @MountedDepots.delete(depot)
            end
        end

        class SharedDepots
            attr_reader :Depots
            def initialize(sharedDepots = {})
                load(sharedDepots)
            end

            def load(sharedDepots)
                raise ArgumentError, "SharedDepots must be instance of Hash" unless sharedDepots.is_a?(Hash)
                @SharedDepots = {}
                sharedDepots.each do |depot, baseDepot|
                    @SharedDepots[depot.to_i] = baseDepot.to_i
                end
            end

            def depots
                @SharedDepots.keys
            end

            def getDepot(depotID)
                @SharedDepots.each do |depot, baseDepot|
                    return baseDepot if depot == depotID
                end
                nil
            end

            def set(depot, baseDepot)
                @SharedDepots[depot] = baseDepot
            end

            def remove(depot)
                @SharedDepots.delete(depot)
            end
        end

        class CheckGuid < ValueArray
        end

        class InstallScripts < ValueArray
        end
    end
end
