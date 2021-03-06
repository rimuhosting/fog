unless Fog.mocking?

  module Fog
    module Rackspace
      class Files

        # Delete an existing container
        #
        # ==== Parameters
        # * container<~String> - Name of container to delete
        # * object<~String> - Name of object to delete
        #
        def delete_object(container, object)
          response = storage_request(
            :expects  => 204,
            :method   => 'DELETE',
            :path     => "#{CGI.escape(container)}/#{CGI.escape(object)}"
          )
          response
        end

      end
    end
  end

else

  module Fog
    module Rackspace
      class Servers

        def delete_object
        end

      end
    end
  end

end
