-- Rockets fired by the launcher SWEPs, loaded by ACF's own loader alongside its missile definitions
-- Every motor burns out in the tube (StarterPercent 1), so the whole impulse is the launch speed and Thrust only has to be non-zero
local Classes = ACF.Classes

Classes.DefineClass("ACF.Missiles.ShoulderFiredRocket", "ACF.Missiles.BaseMissile", function(CLASS)
	CLASS.Name			= "Shoulder-Fired Rockets"
	CLASS.ID			= "SFR"
	CLASS.Description	= "Rockets fired by infantry launchers."
	CLASS.MenuHidden	= true -- Only the SWEPs fire these, they have no rack
	CLASS.Sound			= "acf_missiles/missiles/missile_rocket.mp3"
	-- No CLASS.Effect: the motors burn out in the tube, and these models have no "exhaust" attachment for the trail
	CLASS.Spread		= 0
	CLASS.Blacklist		= { ["ACF.Ammunition.AP"] = true, ["ACF.Ammunition.APHE"] = true, ["ACF.Ammunition.HP"] = true, ["ACF.Ammunition.FL"] = true, ["ACF.Ammunition.SM"] = true }
end)

Classes.DefineClass("ACF.Missiles.ShoulderFiredRocket.M6A3", "ACF.Missiles.ShoulderFiredRocket", function(CLASS)
	CLASS.Name			= "M6A3 Rocket"
	CLASS.Description	= "The 2.36 inch HEAT rocket of the M9A1 Bazooka."
	CLASS.Model			= "models/weapons/panzerschreck/w_panzerschreck_rocket.mdl"
	CLASS.Caliber		= 60
	CLASS.Mass			= 1.5
	CLASS.Length		= 49
	CLASS.Year			= 1944
	CLASS.ReloadTime	= 1
	CLASS.Racks			= {}
	CLASS.Guidances		= { ["ACF.Missiles.Guidance.Dumb"] = true }
	CLASS.Navigation	= "ACF.Missiles.Navigation.Chase"
	CLASS.Fuzes			= { ["ACF.Missiles.Fuze.Contact"] = true }
	CLASS.Agility		= 1
	CLASS.ArmDelay		= 0
	CLASS.HitDeviate	= false
	CLASS.Round			= {
		Model           	= "models/weapons/panzerschreck/w_panzerschreck_rocket.mdl",
		MaxLength       	= 22.3,
		Armor           	= 1,
		ProjLength      	= 19.7,
		PropLength      	= 2.6,
		Thrust          	= 115000, -- in kg*in/s^2
		FuelConsumption 	= 0.01474, -- in g/s/f
		StarterPercent  	= 1,
		MaxAgilitySpeed 	= 1, -- in m/s
		DragCoef        	= 0.0012,
		FinMul          	= 0,
		GLimit          	= 1,
		TailFinMul      	= 0.06,
		PenMul          	= 0.753,
		FillerMul       	= 1,
		LinerMassMul    	= 1,
		Standoff        	= 6,
		GhostingPeriod  	= 0.0125, -- in s
		ActualLength    	= 49,
		ActualWidth     	= 6
	}
end)

Classes.DefineClass("ACF.Missiles.ShoulderFiredRocket.RPzBGr4322", "ACF.Missiles.ShoulderFiredRocket", function(CLASS)
	CLASS.Name			= "RPzB.Gr. 4322 Rocket"
	CLASS.Description	= "The 88mm HEAT rocket of the RPzB 54 Panzerschreck."
	CLASS.Model			= "models/weapons/panzerschreck/w_panzerschreck_rocket.mdl"
	CLASS.Caliber		= 88
	CLASS.Mass			= 3.25
	CLASS.Length		= 65
	CLASS.Year			= 1943
	CLASS.ReloadTime	= 1
	CLASS.Racks			= {}
	CLASS.Guidances		= { ["ACF.Missiles.Guidance.Dumb"] = true }
	CLASS.Navigation	= "ACF.Missiles.Navigation.Chase"
	CLASS.Fuzes			= { ["ACF.Missiles.Fuze.Contact"] = true }
	CLASS.Agility		= 1
	CLASS.ArmDelay		= 0
	CLASS.HitDeviate	= false
	CLASS.Round			= {
		Model           	= "models/weapons/panzerschreck/w_panzerschreck_rocket.mdl",
		MaxLength       	= 26.6,
		Armor           	= 1,
		ProjLength      	= 23.7,
		PropLength      	= 2.9,
		Thrust          	= 115000, -- in kg*in/s^2
		FuelConsumption 	= 0.01219, -- in g/s/f
		StarterPercent  	= 1,
		MaxAgilitySpeed 	= 1, -- in m/s
		DragCoef        	= 0.0026,
		FinMul          	= 0,
		GLimit          	= 1,
		TailFinMul      	= 0.06,
		PenMul          	= 1.206,
		FillerMul       	= 1,
		LinerMassMul    	= 1,
		Standoff        	= 9,
		GhostingPeriod  	= 0.0125, -- in s
		ActualLength    	= 65,
		ActualWidth     	= 9
	}
end)

Classes.DefineClass("ACF.Missiles.ShoulderFiredRocket.Mk6HEAA", "ACF.Missiles.ShoulderFiredRocket", function(CLASS)
	CLASS.Name			= "Mk 6 HEAA Rocket"
	CLASS.Description	= "The 83mm anti-armor rocket of the Mk 153 SMAW."
	CLASS.Model			= "models/acf/munitions/projectile_mortar.mdl"
	CLASS.Caliber		= 83
	CLASS.Mass			= 4.5
	CLASS.Length		= 82
	CLASS.Year			= 1984
	CLASS.ReloadTime	= 1
	CLASS.Racks			= {}
	CLASS.Guidances		= { ["ACF.Missiles.Guidance.Dumb"] = true }
	CLASS.Navigation	= "ACF.Missiles.Navigation.Chase"
	CLASS.Fuzes			= { ["ACF.Missiles.Fuze.Contact"] = true }
	CLASS.Agility		= 1
	CLASS.ArmDelay		= 0
	CLASS.HitDeviate	= false
	CLASS.Bodygroups	= {
		type = {
			DataSource = function() return "HEAT" end,
			HEAT = { OnRack = "HEAT.smd", OnLaunch = "HEAT.smd" },
		},
		fins = {
			DataSource = function() return "Fins" end,
			Fins = { OnRack = "fins.smd", OnLaunch = "fins.smd" },
		},
	}
	CLASS.Round			= {
		Model           	= "models/acf/munitions/projectile_mortar.mdl",
		MaxLength       	= 37.7,
		Armor           	= 1,
		ProjLength      	= 31.9,
		PropLength      	= 5.8,
		Thrust          	= 115000, -- in kg*in/s^2
		FuelConsumption 	= 0.00838, -- in g/s/f
		StarterPercent  	= 1,
		MaxAgilitySpeed 	= 1, -- in m/s
		DragCoef        	= 0.0024,
		FinMul          	= 0,
		GLimit          	= 1,
		TailFinMul      	= 0.06,
		PenMul          	= 1.705,
		FillerMul       	= 2,
		LinerMassMul    	= 1,
		Standoff        	= 8,
		GhostingPeriod  	= 0.0125, -- in s
		ActualLength    	= 82,
		ActualWidth     	= 8
	}
end)
