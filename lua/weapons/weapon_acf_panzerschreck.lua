AddCSLuaFile()

SWEP.Base                   = "weapon_acf_base"
SWEP.PrintName              = "ACF Panzerschreck"

SWEP.IconOffset				= Vector(-2, -8, 0)
SWEP.IconAngOffset			= Angle()

SWEP.UseHands               = false
SWEP.ViewModel              = "models/weapons/panzerschreck/v_panzerschreck.mdl"
SWEP.ViewModelFOV			= 45

SWEP.ShotSound				= Sound("Weapon_Panzerschreck.Shoot")
SWEP.WorldModel             = "models/weapons/panzerschreck/w_pschreck.mdl"
SWEP.HoldType               = "rpg"

SWEP.Slot                   = 4
SWEP.SlotPos                = 0

SWEP.Spawnable              = true
SWEP.AdminOnly              = false

SWEP.m_WeaponDeploySpeed    = 1
SWEP.Spread                 = 0.75
SWEP.RecoilMod              = 0.1

SWEP.Primary.ClipSize       = 1
SWEP.Primary.DefaultClip    = 1
SWEP.Primary.Ammo           = "RPG_Round"
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 0.2
SWEP.CarrySpeedMul			= 0.6

SWEP.UseHybrid				= false

SWEP.Caliber                = 88 -- mm diameter of bullet

SWEP.ACFType                = "HEAT"
SWEP.ACFMuzzleVel           = 110 -- m/s of bullet leaving the barrel
SWEP.ACFProjLen				= 27.1
SWEP.ACFPropMass			= 0.127116 -- kg of propellant
SWEP.Tracer                 = 0

SWEP.IronSightPos           = Vector(-7.4, 0, 5.45)
SWEP.IronSightAng           = Angle(0.1, 0.285, 0)
SWEP.PitchAdjust			= 0

SWEP.SprintAng				= Angle(-5, -10, 0) -- The angle the viewmodel turns to when the player is sprinting

SWEP.AimFocused				= 0.0
SWEP.AimUnfocused			= 5

SWEP.CustomAnim				= true
SWEP.AimAnim				= ACT_VM_DEPLOY
SWEP.IdleAnim				= ACT_VM_UNDEPLOY

SWEP.CustomWorldModelPos	= true -- An attempt at fixing the broken worldmodel position
SWEP.OffsetWorldModelPos	= Vector(0, 0, 1)
SWEP.OffsetWorldModelAng	= Angle(10, 0, 180)

SWEP.FakeFire				= true	-- This shakes the aim bloom so you can't just quickshot to victory
SWEP.MoveBloom				= 2

SWEP.Zoom					= 1.2
SWEP.Recovery				= 0.5

SWEP.RequiresAim			= true
