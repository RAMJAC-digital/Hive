##
# Author:     Sterling Stanford-Jones
# Copyright:      Copyright (C) 2019
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
defmodule Bee.FlightData do
  # bool
  defstruct batteryCritical: nil,
            # bool
            batteryLow: nil,
            # int16
            batteryMilliVolts: nil,
            # int8
            batteryPercentage: nil,
            # bool
            batteryState: nil,
            # uint8
            cameraState: nil,
            # bool
            downVisualState: nil,
            # int16
            droneFlyTimeLeft: nil,
            # bool
            droneHover: nil,
            # int16
            eastSpeed: nil,
            # uint8
            electricalMachineryState: nil,
            # bool
            emOpen: nil,
            # bool
            errorState: nil,
            # bool
            factoryMode: nil,
            # bool
            flying: nil,
            # uint8
            flyMode: nil,
            # int16
            flyTime: nil,
            # bool
            frontIn: nil,
            # bool
            frontLSC: nil,
            # bool
            frontOut: nil,
            # bool
            gravityState: nil,
            # int16
            groundSpeed: nil,
            # int16 // seems to be in decimetres
            height: nil,
            # IMUData
            imu: nil,
            # int8
            imuCalibrationState: nil,
            # bool
            imuState: nil,
            # uint8
            lightStrength: nil,
            # uint8
            lowBatteryThreshold: nil,
            # uint8
            maxHeight: nil,
            # MVOData
            mvo: nil,
            # int16
            northSpeevo: nil,
            # bool
            onGround: nil,
            # bool
            outageRecording: nil,
            # bool
            powerState: nil,
            # bool
            pressureState: nil,
            # int16
            smartVideoExitMode: nil,
            # string
            ssid: nil,
            # int8
            throwFlyTimer: nil,
            # string
            version: nil,
            # int16
            verticalSpeed: nil,
            # VBR
            videoBitrate: nil,
            # uint8
            wifiInterference: nil,
            # uint8
            wifiStrength: nil,
            # bool
            windState: nil

  # MVOData comes from the flight log messages
  defmodule Bee.FlightData.MVOData do
    # float32
    defstruct positionX: nil,
              positionY: nil,
              positionZ: nil,
              # int16
              velocityX: nil,
              velocityY: nil,
              velocityZ: nil
  end

  # IMUData comes from the flight log messages
  defmodule Bee.FlightData.IMUData do
    defstruct quaternionW: nil,
              # float32
              quaternionX: nil,
              quaternionY: nil,
              quaternionZ: nil,
              # int16
              temperature: nil,
              # int16 // derived from Quat fields, -180 > degrees > +180
              yaw: nil
  end
end
