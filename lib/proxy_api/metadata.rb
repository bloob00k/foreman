module ProxyAPI
  class Metadata < ProxyAPI::Resource
    def initialize(args)
      @url     = args[:url] + "/metadata"
      @variant = args[:variant]
      super args
    end

    # Creates a Metadata entry
    # [+IP+]  : IP address
    # [+args+] : Hash containing
    #    
    # Returns  : Boolean status
    def set(ip, key, value)     
      parse(post({:value => value}, "#{ip}/#{key}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to set metadata entry for %s"), ip)
    end

    # Deletes a metadata boot entry
    # [+ip+] : String in dotted quad format
    # Returns : Boolean status
    def delete(ip)
      parse(super("#{ip}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete metadata entry for %s"), ip)
    end

    
    # returns the metadata server for this proxy
    def bootServer
      if (response = parse(get("serverName"))) and response["serverName"].present?
        return response["serverName"]
      end
      false
    rescue RestClient::ResourceNotFound
      nil
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to detect metadata server"))
    end

  end
end

