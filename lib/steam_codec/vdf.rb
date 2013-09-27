# encoding: UTF-8
module SteamCodec
    class VDF < KeyValues
        # About VDF => http://wiki.teamfortress.com/wiki/WebAPI/VDF
        def self.loadFromFile(file)
            vdf = KeyValues::loadFromFile(file)
            return self[vdf] if vdf
            nil
        end

        def self.load(data)
            vdf = KeyValues::load(data)
            return self[vdf] if vdf
            nil
        end

        def isSignaturesValid?(publicKey)
            return true unless key?("kvsignatures")
            self["kvsignatures"].each do |key, signature|
                # TODO
                return false
            end
            true
        end

    end
end
