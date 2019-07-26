
## 
# Author:     Sterling Stanford-Jones
# Copyright:      Copyright (C) 2019  <name of author>
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
  defstruct batteryCritical:          nil, #bool
            batteryLow:               nil, #bool
            batteryMilliVolts:        nil, #int16
            batteryPercentage:        nil, #int8
            batteryState:             nil, #bool
            cameraState:              nil, #uint8
            downVisualState:          nil, #bool
            droneFlyTimeLeft:         nil, #int16
            droneHover:               nil, #bool
            eastSpeed:                nil, #int16
            electricalMachineryState: nil, #uint8
            emOpen:                   nil, #bool
            errorState:               nil, #bool
            factoryMode:              nil, #bool
            flying:                   nil, #bool
            flyMode:                  nil, #uint8
            flyTime:                  nil, #int16
            frontIn:                  nil, #bool
            frontLSC:                 nil, #bool
            frontOut:                 nil, #bool
            gravityState:             nil, #bool
            groundSpeed:              nil, #int16
            height:                   nil, #int16 // seems to be in decimetres
            imu:                      nil, #IMUData
            imuCalibrationState:      nil, #int8
            imuState:                 nil, #bool
            lightStrength:            nil, #uint8
            lowBatteryThreshold:      nil, #uint8
            maxHeight:                nil, #uint8
            mvo:                      nil, #MVOData
            northSpeevo:              nil, #int16
            onGround:                 nil, #bool
            outageRecording:          nil, #bool
            powerState:               nil, #bool
            pressureState:            nil, #bool
            smartVideoExitMode:       nil, #int16
            ssid:                     nil, #string
            throwFlyTimer:            nil, #int8
            version:                  nil, #string
            verticalSpeed:            nil, #int16
            videoBitrate:             nil, #VBR
            wifiInterference:         nil, #uint8
            wifiStrength:             nil, #uint8
            windState:                nil #bool

  # MVOData comes from the flight log messages
  defmodule Bee.FlightData.MVOData do
    defstruct positionX: nil, positionY: nil, positionZ: nil, #float32
              velocityX: nil, velocityY: nil, velocityZ: nil  #int16
  end

  # IMUData comes from the flight log messages
  defmodule Bee.FlightData.IMUData do
    defstruct quaternionW: nil,
              quaternionX: nil, quaternionY: nil, quaternionZ: nil, #float32
              temperature: nil, #int16
              yaw:         nil #int16 // derived from Quat fields, -180 > degrees > +180
  end
end
