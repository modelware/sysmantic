// A 3U Earth-observation CubeSat in a 500 km sun-synchronous orbit: its subsystems and the power
// each draws in each operating mode, its modes and what moves it between them, how it downlinks its
// images on a ground-station pass, its shape, and its power requirements. How its battery fares
// through a day of orbits is an analysis's answer (the notebook's).

package EarthObserver {
	private import ISQ::*;
	private import SI::*;
	private import ScalarValues::*;
	private import ShapeItems::*;
	private import SpatialItems::*;
	private import MeasurementReferences::*;

	// ---- Interfaces ----

	port def PowerBus {
		doc /* The regulated 3.3 V and 5 V rails, and the unregulated battery bus. */
	}
	port def DataBus {
		doc /* CAN between the on-board computer and the subsystems. */
	}
	port def RadioFrequency {
		doc /* Coaxial feed to an antenna. */
	}

	// ---- What draws power: the power budget, by operating mode ----

	public import Loads::*;
	package Loads {
		private import ISQ::*;
		private import SI::*;
		private import ShapeItems::*;

		part def Load {
			doc /* Something that draws power: how much in each operating mode. */
			attribute safePower :> ISQ::power default = 0 [W];
			attribute idlePower :> ISQ::power default = 0 [W];
			attribute imagingPower :> ISQ::power default = 0 [W];
			attribute downlinkPower :> ISQ::power default = 0 [W];
			port power : ~PowerBus;
		}

		part def OnboardComputer :> Load {
			doc /* Runs the mode logic, stores images (32 GB), and schedules passes. */
			attribute :>> safePower = 0.4 [W];
			attribute :>> idlePower = 0.4 [W];
			attribute :>> imagingPower = 0.6 [W];
			attribute :>> downlinkPower = 0.6 [W];
			attribute mass :> ISQ::mass = 0.10 [kg];
			port bus : DataBus;
		}

		part def AttitudeControl :> Load {
			doc /* Three reaction wheels, magnetorquers, a star tracker and sun sensors. Sun-pointing when idle,
			 * fine pointing at a target when imaging, tracking the ground station when downlinking. */
			attribute :>> safePower = 0.5 [W];
			attribute :>> idlePower = 1.3 [W];
			attribute :>> imagingPower = 2.6 [W];
			attribute :>> downlinkPower = 2.2 [W];
			attribute mass :> ISQ::mass = 0.65 [kg];
			port bus : ~DataBus;
		}

		part def UhfRadio :> Load {
			doc /* UHF telemetry and command: always listening. */
			attribute :>> safePower = 0.3 [W];
			attribute :>> idlePower = 0.3 [W];
			attribute :>> imagingPower = 0.3 [W];
			attribute :>> downlinkPower = 1.8 [W];
			attribute mass :> ISQ::mass = 0.09 [kg];
			port bus : ~DataBus;
			port antenna : RadioFrequency;
		}

		part def SBandTransmitter :> Load {
			doc /* The image downlink: 2 Mbit/s, on only over a ground station. */
			attribute :>> downlinkPower = 9.5 [W];
			attribute dataRate :> ISQ::frequency = 2000000 [Hz];
			attribute mass :> ISQ::mass = 0.14 [kg];
			port bus : ~DataBus;
			port antenna : RadioFrequency;
		}

		part def Imager :> Load, CircularCylinder {
			doc /* A multispectral imager, 5 m ground sampling distance: its lens drawn as a cylinder. */
			attribute :>> radius = 40 [mm];
			attribute :>> height = 60 [mm];
			attribute :>> imagingPower = 6.5 [W];
			attribute :>> idlePower = 0.2 [W];
			attribute mass :> ISQ::mass = 0.80 [kg];
			port bus : ~DataBus;
		}
	}

	// ---- Power ----

	part def SolarPanel :> RectangularCuboid {
		doc /* A 3U panel of triple-junction cells, 29.5 % efficient: its power with the sun square on it. */
		attribute :>> length default = 3 [mm];
		attribute :>> width default = 300 [mm];
		attribute :>> height default = 340 [mm];
		attribute peakPower :> ISQ::power default = 7.6 [W];
		attribute mass :> ISQ::mass default = 0.15 [kg];
		port output : PowerBus;
	}

	part def Battery {
		doc /* Four 18650 lithium-ion cells, two in series, two strings in parallel. */
		attribute capacity :> ISQ::energy default = 50 [W*h];
		attribute mass :> ISQ::mass default = 0.20 [kg];
		port terminals : PowerBus;
	}

	part def PowerSystem {
		doc /* The electrical power system: maximum-power-point trackers, battery charge control, rails. */
		attribute mass :> ISQ::mass = 0.12 [kg];
		port solarLeft : ~PowerBus;
		port solarRight : ~PowerBus;
		port solarBody : ~PowerBus;
		port battery : ~PowerBus;
		port rails : PowerBus;
		port bus : ~DataBus;
	}

	part def Structure :> RectangularCuboid {
		doc /* The 3U aluminium frame: 10 × 10 × 34 cm. */
		attribute :>> length = 100 [mm];
		attribute :>> width = 100 [mm];
		attribute :>> height = 340 [mm];
		attribute mass :> ISQ::mass = 0.45 [kg];
	}

	part def Antenna :> CircularCylinder {
		attribute :>> radius = 2 [mm];
		attribute :>> height = 170 [mm];
		port feed : ~RadioFrequency;
	}

	part def PatchAntenna :> RectangularCuboid {
		attribute :>> length = 40 [mm];
		attribute :>> width = 40 [mm];
		attribute :>> height = 4 [mm];
		port feed : ~RadioFrequency;
	}

	// ---- The satellite ----

	part def CubeSat :> SpatialItem {
		doc /* Placed by their centers in the satellite's frame: z along the long axis (the imager looks down −z,
		 * at nadir), the deployed panels out along ±y, their cells facing +x. */

		part structure : Structure {
			attribute :>> coordinateFrame { attribute :>> transformation = new TranslationRotationSequence(new Translation((0, 0, 0)[coordinateFrame])); }
		}
		part leftPanel : SolarPanel {
			attribute :>> coordinateFrame { attribute :>> transformation = new TranslationRotationSequence(new Translation((0, 0.205, 0)[coordinateFrame])); }
		}
		part rightPanel : SolarPanel {
			attribute :>> coordinateFrame { attribute :>> transformation = new TranslationRotationSequence(new Translation((0, -0.205, 0)[coordinateFrame])); }
		}
		part bodyPanel : SolarPanel {
			doc /* The cells on the +x face of the body. */
			attribute :>> width = 100 [mm];
			attribute :>> peakPower = 2.4 [W];
			attribute :>> mass = 0.05 [kg];
			attribute :>> coordinateFrame { attribute :>> transformation = new TranslationRotationSequence(new Translation((0.052, 0, 0)[coordinateFrame])); }
		}
		part imager : Imager {
			attribute :>> coordinateFrame { attribute :>> transformation = new TranslationRotationSequence(new Translation((0, 0, -0.2)[coordinateFrame])); }
		}
		part uhfAntenna : Antenna {
			attribute :>> coordinateFrame {
				attribute :>> transformation = new TranslationRotationSequence(
					new Translation((0, 0, 0.172)[coordinateFrame]), new Rotation((1, 0, 0)[coordinateFrame], 90 ['°']));
			}
		}
		part sBandPatch : PatchAntenna {
			attribute :>> coordinateFrame { attribute :>> transformation = new TranslationRotationSequence(new Translation((0.03, 0.03, -0.172)[coordinateFrame])); }
		}

		// Inside the frame.
		part battery : Battery;
		part eps : PowerSystem;
		part obc : OnboardComputer;
		part adcs : AttitudeControl;
		part uhf : UhfRadio;
		part sBand : SBandTransmitter;

		connect leftPanel.output to eps.solarLeft;
		connect rightPanel.output to eps.solarRight;
		connect bodyPanel.output to eps.solarBody;
		connect battery.terminals to eps.battery;
		connect eps.rails to obc.power;
		connect eps.rails to adcs.power;
		connect eps.rails to uhf.power;
		connect eps.rails to sBand.power;
		connect eps.rails to imager.power;
		connect obc.bus to eps.bus;
		connect obc.bus to adcs.bus;
		connect obc.bus to uhf.bus;
		connect obc.bus to sBand.bus;
		connect obc.bus to imager.bus;
		connect uhf.antenna to uhfAntenna.feed;
		connect sBand.antenna to sBandPatch.feed;

		// ---- Budgets: what the loads draw in each mode ----

		attribute safeLoad :> ISQ::power = obc.safePower + adcs.safePower + uhf.safePower + sBand.safePower + imager.safePower;
		attribute idleLoad :> ISQ::power = obc.idlePower + adcs.idlePower + uhf.idlePower + sBand.idlePower + imager.idlePower;
		attribute imagingLoad :> ISQ::power = obc.imagingPower + adcs.imagingPower + uhf.imagingPower + sBand.imagingPower + imager.imagingPower;
		attribute downlinkLoad :> ISQ::power = obc.downlinkPower + adcs.downlinkPower + uhf.downlinkPower + sBand.downlinkPower + imager.downlinkPower;

		/* The lowest state of charge over a day of orbits, and the images taken in it: the power
		 * simulation's answers. */
		attribute lowestCharge : Real;
		attribute imagesPerDay : Integer;

		exhibit state modes : OperatingModes;
	}

	part satellite : CubeSat;

	// ---- Operating modes ----

	item def TargetInView { doc /* The ground track reaches a target in the imaging plan. */ }
	item def StationInView { doc /* A ground station rises above 10° elevation. */ }
	item def PassComplete { doc /* The station sets, or the image queue is empty. */ }

	state def OperatingModes {
		doc /* What the satellite is doing, and so what each subsystem draws. */
		attribute stateOfCharge : Real;

		entry; then safe;

		state safe {
			doc /* Detumbled, sun-seeking on magnetorquers, everything but the UHF radio off: after
			 * separation, and whenever the battery runs low. */
		}
		state idle {
			doc /* Sun-pointing, charging. */
			entry action pointAtSun;
		}
		state imaging {
			doc /* Pointing at the target, imaging for up to 8 minutes. */
			entry action pointAtTarget;
			do action captureImages;
		}
		state downlink {
			doc /* Tracking the ground station, sending the queued images. */
			do action pass : DownlinkPass;
		}

		transition recovered first safe accept when stateOfCharge > 0.6 then idle;
		transition target first idle accept TargetInView if stateOfCharge > 0.5 then imaging;
		transition imaged first imaging accept after 8 [min] then idle;
		transition station first idle accept StationInView then downlink;
		transition passed first downlink accept PassComplete then idle;
		transition lowFromIdle first idle accept when stateOfCharge < 0.3 then safe;
		transition lowFromImaging first imaging accept when stateOfCharge < 0.3 then safe;
	}

	// ---- A ground-station pass ----

	action def DownlinkPass {
		doc /* Sending the image queue to a ground station, while it is in view. */
		in attribute queued : Integer;

		first start;
		then action acquireBeacon { doc /* Lock onto the station's UHF beacon. */ }
		then action trackStation { doc /* Slew to point the S-band patch at the station. */ }
		then action authenticate { doc /* Exchange keys over UHF; the station authorizes the downlink. */ }
		then merge nextImage;
		then decide moreToSend;
			if queued > 0 then sendImage;
			else closeLink;

		action sendImage { doc /* Send one image over S-band; the station acknowledges it. */ }
		then nextImage;

		action closeLink { doc /* Report what was sent, switch the S-band transmitter off. */ }
		then done;
	}

	item def Beacon;
	item def Handshake;
	item def Authorization;
	item def ImageData;
	item def Acknowledgement;

	occurrence def GroundPass {
		doc /* One pass over the ground station, as the two of them see it. */
		part station {
			event occurrence sendBeacon;
			then event occurrence receiveHandshake;
			then event occurrence sendAuthorization;
			then event occurrence receiveImage;
			then event occurrence sendAcknowledgement;
		}
		part spacecraft {
			event occurrence receiveBeacon;
			then event occurrence sendHandshake;
			then event occurrence receiveAuthorization;
			then event occurrence sendImage;
			then event occurrence receiveAcknowledgement;
		}
		message beacon of Beacon from station.sendBeacon to spacecraft.receiveBeacon;
		message handshake of Handshake from spacecraft.sendHandshake to station.receiveHandshake;
		message authorization of Authorization from station.sendAuthorization to spacecraft.receiveAuthorization;
		message image of ImageData from spacecraft.sendImage to station.receiveImage;
		message acknowledgement of Acknowledgement from station.sendAcknowledgement to spacecraft.receiveAcknowledgement;
	}

	// ---- Requirements ----

	package Requirements {
		requirement def <'EPS-1'> DepthOfDischarge {
			doc /* The battery shall never discharge below 70 % of its capacity in nominal operations:
			 * to keep the cells' cycle life over a three-year mission (some 16 000 cycles). */
			subject s : CubeSat;
			attribute floor : Real = 0.70;
			require constraint { s.lowestCharge >= floor }
		}
		requirement def <'MIS-1'> ImagingCapacity {
			doc /* The satellite shall image at least 8 targets a day. */
			subject s : CubeSat;
			attribute minimum : Integer = 8;
			require constraint { s.imagesPerDay >= minimum }
		}

		requirement depthOfDischarge : DepthOfDischarge { subject :>> s = satellite; }
		requirement imagingCapacity : ImagingCapacity { subject :>> s = satellite; }
		satisfy depthOfDischarge by satellite;
		satisfy imagingCapacity by satellite;
	}
}
