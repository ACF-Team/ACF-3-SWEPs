AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF SMAW"

SWEP.IconOffset				= Vector(4, -4, 0)
SWEP.IconAngOffset			= Angle(0 , -85 , 0)

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/reshed_acfextras/at/acf_smawrecoilessrifle.mdl"
SWEP.ViewModelFOV			= 90

SWEP.ShotSound				= Sound("weapons/smaw/fire2.wav")
SWEP.WorldModel             = "models/weapons/reshed_acfextras/at/col_acf_smawrecoilessrifle.mdl"
SWEP.HoldType               = "passive"

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.1 -- Slightly tighter spread, SMAW is accurate
SWEP.RecoilMod              = 1 -- Recoilless rifle, minimal felt recoil

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "RPG_Round"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.15
SWEP.CarrySpeedMul			= 0.6

SWEP.UseHybrid				= false

-- SMAW Mk 153 fires 83mm rockets
SWEP.Caliber                = 83 -- mm diameter (SMAW is 83mm)
SWEP.ACFType                = "HEAT"
SWEP.ACFMuzzleVel           = 220 -- m/s (SMAW HEAA muzzle velocity)
SWEP.ACFProjLen				= 28 -- Longer projectile for 83mm
SWEP.ACFPropMass			= 0.12 -- kg of propellant
SWEP.Tracer                 = 1 -- SMAW rounds have visible tracer

-- Aim table adjusted for 220 m/s muzzle velocity (flatter trajectory)
SWEP.AimTable = {}
SWEP.AimTable[1] = {IronPos = Vector(-2.95, 0, -0.7), IronAng = Angle(0, 0, -5),  PitchAdjust = 0, Text = "100m"} -- 100m

SWEP.AimFocused				= 0.5 -- Tighter aim when focused (better optics simulation)
SWEP.AimUnfocused			= 4

SWEP.SprintPos				= Vector(0.34, 3.49, 4.2) -- The position the viewmodel moves to when the player is sprinting
SWEP.SprintAng				= Angle(-20.532, 10.793, -14.963) -- The angle the viewmodel turns to when the player is sprinting

--Bruh do yall not have a 3d artist for source
SWEP.CustomWorldModelPos	= false -- An attempt at fixing the broken worldmodel position

SWEP.FakeFire				= true	-- This shakes the aim bloom so you can't just quickshot to victory
SWEP.MoveBloom				= 1.5 -- Slightly less bloom, weapon is balanced

SWEP.Zoom					= 1.5 -- SMAW has better optics
SWEP.Recovery				= 0.3 -- Faster recovery due to recoilless design

SWEP.RequiresAim			= true
SWEP.AimHoldType			= "rpg"
SWEP.PunchAmount			= 0.225 -- Recoilless rifle: drastically reduced recoil

function SWEP:CalcView( _, pos, ang, _ )
	local ViewModel = self:GetOwner():GetViewModel()
	if not IsValid(ViewModel) then return pos, ang end

	local attachment = ViewModel:GetAttachment( ViewModel:LookupAttachment( "1" ) )
	if not attachment then return pos, ang end

	ang = ang + ViewModel:WorldToLocalAngles( attachment.Ang )
	return pos, ang
end

sound.Add({
	name = 			"rshd_acf.SMAWRaise",
	channel = 		CHAN_AUTO,
	volume = 		1.0,
	sound = 			"weapons/smaw/raise.wav"
})

sound.Add({
	name = 			"rshd_acf.SMAWOut",
	channel = 		CHAN_AUTO,
	volume = 		1.0,
	sound = 			"weapons/smaw/out.wav"
})

sound.Add({
	name = 			"rshd_acf.SMAWIn",
	channel = 		CHAN_AUTO,
	volume = 		1.0,
	sound = 			"weapons/smaw/in.wav"
})

sound.Add({
	name = 			"rshd_acf.SMAWLower",
	channel = 		CHAN_AUTO,
	volume = 		1.0,
	sound = 			"weapons/smaw/reshoulderlol.wav"
})