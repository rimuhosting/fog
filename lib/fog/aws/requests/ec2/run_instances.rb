unless Fog.mocking?

  module Fog
    module AWS
      class EC2

        # Launch specified instances
        #
        # ==== Parameters
        # * image_id<~String> - Id of machine image to load on instances
        # * min_count<~Integer> - Minimum number of instances to launch. If this
        #   exceeds the count of available instances, no instances will be
        #   launched.  Must be between 1 and maximum allowed for your account
        #   (by default the maximum for an account is 20)
        # * max_count<~Integer> - Maximum number of instances to launch. If this
        #   exceeds the number of available instances, the largest possible
        #   number of instances above min_count will be launched instead. Must
        #   be between 1 and maximum allowed for you account
        #   (by default the maximum for an account is 20)
        # * options<~Hash>:
        #   * 'Placement.AvailabilityZone'<~String> - Placement constraint for instances
        #   * 'DeviceName'<~String> - ?
        #   * 'Encoding'<~String> - ?
        #   * 'groupId'<~String> - Name of security group for instances
        #   * 'InstanceType'<~String> - Type of instance to boot. Valid options
        #     in ['m1.small', 'm1.large', 'm1.xlarge', 'c1.medium', 'c1.xlarge']
        #     default is 'm1.small'
        #   * 'KernelId'<~String> - Id of kernel with which to launch
        #   * 'KeyName'<~String> - Name of a keypair to add to booting instances
        #   * 'Monitoring.Enabled'<~Boolean> - Enables monitoring, defaults to 
        #     disabled
        #   * 'RamdiskId'<~String> - Id of ramdisk with which to launch
        #   * 'UserData'<~String> -  Additional data to provide to booting instances
        #   * 'Version'<~String> - ?
        #   * 'VirtualName'<~String> - ?
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'groupSet'<~Array>: groups the instances are members in
        #       * 'groupName'<~String> - Name of group
        #     * 'instancesSet'<~Array>: returned instances
        #       * instance<~Hash>:
        #         * 'amiLaunchIndex'<~Integer> - reference to instance in launch group
        #         * 'dnsName'<~String> - public dns name, blank until instance is running
        #         * 'imageId'<~String> - image id of ami used to launch instance
        #         * 'instanceId'<~String> - id of the instance
        #         * 'instanceState'<~Hash>:
        #           * 'code'<~Integer> - current status code
        #           * 'name'<~String> - current status name
        #         * 'instanceType'<~String> - type of instance
        #         * 'kernelId'<~String> - Id of kernel used to launch instance
        #         * 'keyName'<~String> - name of key used launch instances or blank
        #         * 'launchTime'<~Time> - time instance was launched
        #         * 'monitoring'<~Hash>:
        #           * 'state'<~Boolean - state of monitoring
        #         * 'placement'<~Hash>:
        #           * 'availabilityZone'<~String> - Availability zone of the instance
        #         * 'privateDnsName'<~String> - private dns name, blank until instance is running
        #         * 'productCodes'<~Array> - Product codes for the instance
        #         * 'ramdiskId'<~String> - Id of ramdisk used to launch instance
        #         * 'reason'<~String> - reason for most recent state transition, or blank
        #     * 'ownerId'<~String> - Id of owner
        #     * 'requestId'<~String> - Id of request
        #     * 'reservationId'<~String> - Id of reservation
        def run_instances(image_id, min_count, max_count, options = {})
          if options['UserData']
            options['UserData'] = Base64.encode64(options['UserData'])
          end
          request({
            'Action' => 'RunInstances',
            'ImageId' => image_id,
            'MinCount' => min_count,
            'MaxCount' => max_count
          }.merge!(options), Fog::Parsers::AWS::EC2::RunInstances.new)
        end

      end
    end
  end

else

  module Fog
    module AWS
      class EC2

        def run_instances(image_id, min_count, max_count, options = {})
          response = Excon::Response.new
          response.status = 200

          group_set = [ (options['GroupId'] || 'default') ]
          instances_set = []
          owner_id = Fog::AWS::Mock.owner_id
          reservation_id = Fog::AWS::Mock.reservation_id

          min_count.times do |i|
            instance_id = Fog::AWS::Mock.instance_id
            data = {
              'amiLaunchIndex'  => i,
              'dnsName'         => '',
              'groupSet'        => group_set,
              'imageId'         => image_id,
              'instanceId'      => instance_id,
              'instanceState'   => { 'code' => 0, 'name' => 'pending' },
              'instanceType'    => options['InstanceType'] || 'm1.small',
              'kernelId'        => options['KernelId'] || Fog::AWS::Mock.kernel_id,
              'keyName'         => options['KeyName'] || '',
              'launchTime'      => Time.now,
              'monitoring'      => { 'state' => options['Monitoring.Enabled'] || false },
              'ownerId'         => owner_id,
              'placement'       => { 'availabilityZone' => options['Placement.AvailabilityZone'] || Fog::AWS::Mock.availability_zone },
              'privateDnsName'  => '',
              'productCodes'    => [],
              'ramdiskId'       => options['RamdiskId'] || Fog::AWS::Mock.ramdisk_id,
              'reason'          => '',
              'reservationId'   => reservation_id,
              'instanceState'   => 'pending'
            }
            Fog::AWS::EC2.data[:instances][instance_id] = data
            instances_set << data.reject{|key,value| !['amiLaunchIndex', 'dnsName', 'imageId', 'instanceId', 'instanceState', 'instanceType', 'kernelId', 'keyName', 'launchTime', 'monitoring', 'placement', 'privateDnsName', 'productCodes', 'ramdiskId', 'reason'].include?(key)}
          end
          response.body = {
            'groupSet'      => group_set,
            'instancesSet'  => instances_set,
            'ownerId'       => owner_id,
            'requestId'     => Fog::AWS::Mock.request_id,
            'reservationId' => reservation_id
          }
          response
        end

      end
    end
  end

end
