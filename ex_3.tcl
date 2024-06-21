# SET UP ----------------------------------------------------------------------------
wipe;				# clear memory of all past model definitions
model BasicBuilder -ndm 3 -ndf 6;	# Define the model builder, ndm=#dimension, ndf=#dofs

proc BuildRCrectSection {id HSec BSec coverH coverB coreID coverID steelID numBarsTop barAreaTop numBarsBot barAreaBot numBarsIntTot barAreaInt nfCoreY nfCoreZ nfCoverY nfCoverZ} {
	set coverY [expr $HSec/2.0];		# The distance from the section z-axis to the edge of the cover concrete -- outer edge of cover concrete
	set coverZ [expr $BSec/2.0];		# The distance from the section y-axis to the edge of the cover concrete -- outer edge of cover concrete
	set coreY [expr $coverY-$coverH];		# The distance from the section z-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concrete
	set coreZ [expr $coverZ-$coverB];		# The distance from the section y-axis to the edge of the core concrete --  edge of the core concrete/inner edge of cover concrete
	set numBarsInt [expr $numBarsIntTot/2];	# number of intermediate bars per side

	# Define the fiber section
	section fiberSec $id -GJ 1.0 {
		# Define the core patch
		patch quadr $coreID $nfCoreZ $nfCoreY -$coreY $coreZ -$coreY -$coreZ $coreY -$coreZ $coreY $coreZ
	   
		# Define the four cover patches
		patch quadr $coverID 2 $nfCoverY -$coverY $coverZ -$coreY $coreZ $coreY $coreZ $coverY $coverZ
		patch quadr $coverID 2 $nfCoverY -$coreY -$coreZ -$coverY -$coverZ $coverY -$coverZ $coreY -$coreZ
		patch quadr $coverID $nfCoverZ 2 -$coverY $coverZ -$coverY -$coverZ -$coreY -$coreZ -$coreY $coreZ
		patch quadr $coverID $nfCoverZ 2 $coreY $coreZ $coreY -$coreZ $coverY -$coverZ $coverY $coverZ	

		# define reinforcing layers
		layer straight $steelID $numBarsInt $barAreaInt  -$coreY $coreZ $coreY $coreZ;	# intermediate skin reinf. +z
		layer straight $steelID $numBarsInt $barAreaInt  -$coreY -$coreZ $coreY -$coreZ;	# intermediate skin reinf. -z
		layer straight $steelID $numBarsTop $barAreaTop $coreY $coreZ $coreY -$coreZ;	# top layer reinfocement
		layer straight $steelID $numBarsBot $barAreaBot  -$coreY $coreZ  -$coreY -$coreZ;	# bottom layer reinforcement

	};	# end of fibersection definition
};		# end of procedure



# define GEOMETRY -------------------------------------------------------------
# define structure-geometry paramters
set LCol 3.5;		# column height (parallel to Y axis)
set LBeam 9.0;		# beam length (parallel to X axis)
set LGird 7.0;		# girder length (parallel to Z axis)

# ------ frame configuration
set Ubig 1.e10; 			# a really large number
set Usmall [expr 1/$Ubig]; 		# a really small number


# define NODAL COORDINATES
# calculate locations of beam/column intersections:
node 100000 [expr 0*$LBeam] [expr 0*$LCol] [expr 0*$LGird];	
node 010 [expr 1*$LBeam] [expr 0*$LCol] [expr 0*$LGird];
node 001 [expr 0*$LBeam] [expr 0*$LCol] [expr 1*$LGird];	
node 011 [expr 1*$LBeam] [expr 0*$LCol] [expr 1*$LGird];

node 100 [expr 0*$LBeam] [expr 1*$LCol] [expr 0*$LGird];	
node 110 [expr 1*$LBeam] [expr 1*$LCol] [expr 0*$LGird];
node 101 [expr 0*$LBeam] [expr 1*$LCol] [expr 1*$LGird];	
node 111 [expr 1*$LBeam] [expr 1*$LCol] [expr 1*$LGird];

node 200 [expr 0*$LBeam] [expr 2*$LCol] [expr 0*$LGird];	
node 210 [expr 1*$LBeam] [expr 2*$LCol] [expr 0*$LGird];
node 201 [expr 0*$LBeam] [expr 2*$LCol] [expr 1*$LGird];	
node 211 [expr 1*$LBeam] [expr 2*$LCol] [expr 1*$LGird];

node 300 [expr 0*$LBeam] [expr 3*$LCol] [expr 0*$LGird];	
node 310 [expr 1*$LBeam] [expr 3*$LCol] [expr 0*$LGird];
node 301 [expr 0*$LBeam] [expr 3*$LCol] [expr 1*$LGird];	
node 311 [expr 1*$LBeam] [expr 3*$LCol] [expr 1*$LGird];

node 400 [expr 0*$LBeam] [expr 4*$LCol] [expr 0*$LGird];	
node 410 [expr 1*$LBeam] [expr 4*$LCol] [expr 0*$LGird];
node 401 [expr 0*$LBeam] [expr 4*$LCol] [expr 1*$LGird];	
node 411 [expr 1*$LBeam] [expr 4*$LCol] [expr 1*$LGird];

node 500 [expr 0*$LBeam] [expr 5*$LCol] [expr 0*$LGird];	
node 510 [expr 1*$LBeam] [expr 5*$LCol] [expr 0*$LGird];
node 501 [expr 0*$LBeam] [expr 5*$LCol] [expr 1*$LGird];	
node 511 [expr 1*$LBeam] [expr 5*$LCol] [expr 1*$LGird];


set LBuilding [expr 5*$LCol];	
set Xa        [expr 1*$LBeam/2];		# mid-span coordinate for rigid diaphragm
set Za        [expr 1*$LGird/2];


# define Rigid Floor Diaphragm
set RigidDiaphragm ON ;		# options: ON, OFF. specify this before the analysis parameters are set the constraints are handled differently.
# rigid-diaphragm nodes in center of each diaphram
set RigidDiaphragm ON ;		# this communicates to the analysis parameters that I will be using rigid diaphragms
node 1001 $Xa [expr 1*$LCol] $Za;		# master nodes for rigid diaphragm -- story 2, bay 1, frame 1-2
node 2001 $Xa [expr 2*$LCol] $Za;		# master nodes for rigid diaphragm -- story 3, bay 1, frame 1-2
node 3001 $Xa [expr 3*$LCol] $Za;		# master nodes for rigid diaphragm -- story 4, bay 1, frame 1-2
node 4001 $Xa [expr 4*$LCol] $Za;		# master nodes for rigid diaphragm -- story 4, bay 1, frame 1-2
node 5001 $Xa [expr 5*$LCol] $Za;		# master nodes for rigid diaphragm -- story 4, bay 1, frame 1-2

# Constraints for rigid diaphragm master nodes
fix 1001 0  1  0  1  0  1
fix 2001 0  1  0  1  0  1
fix 3001 0  1  0  1  0  1
fix 4001 0  1  0  1  0  1
fix 5001 0  1  0  1  0  1

# ------------------------define Rigid Diaphram, dof 2 is normal to floor
set perpDirn 2;
rigidDiaphragm $perpDirn 1001 100 101 110 111;	
rigidDiaphragm $perpDirn 2001 200 201 210 211;	
rigidDiaphragm $perpDirn 3001 300 301 310 311;
rigidDiaphragm $perpDirn 4001 400 401 410 411;
rigidDiaphragm $perpDirn 5001 500 501 510 511;	

# BOUNDARY CONDITIONS
fixY 0.0  1 1 1 0 1 0;		# pin all Y=0.0 nodes

# calculated MODEL PARAMETERS, particular to this model

# Define SECTIONS -------------------------------------------------------------
set SectionType FiberSection ;		# options: Elastic FiberSection

# define section tags:
set ColSecTag 1
set BeamSecTag 2
set GirdSecTag 3
set ColSecTagFiber 4
set BeamSecTagFiber 5
set GirdSecTagFiber 6
set SecTagTorsion 70

# Section Properties:
set HCol 0.6;		# square-Column width
set BCol 0.6
set HBeam 0.8;		# Beam depth -- perpendicular to bending axis
set BBeam 0.6;		# Beam width -- parallel to bending axis
set HGird 0.6;		# Girder depth -- perpendicular to bending axis
set BGird 0.6;		# Girder width -- parallel to bending axis

# MATERIAL parameters 
# General Material parameters
set G $Ubig;		# make stiff shear modulus
set J 1.0;			# torsional section stiffness (G makes GJ large)
set GJ [expr $G*$J];

# -----------------------------------------------------------------------------------------------------# confined and unconfined CONCRETE
# nominal concrete compressive strength
set fc 		-24.5E6;		# CONCRETE Compressive Strength, ksi   (+Tension, -Compression)
set Ec 		24.8E9;	# Concrete Elastic Modulus
set nu 0.2;
set Gc [expr $Ec/2./[expr 1+$nu]];  	# Torsional stiffness Modulus

# confined concrete
set Kfc 1.3;			# ratio of confined to unconfined concrete strength
set Kres 0.2;			# ratio of residual/ultimate to maximum stress
set fc1C [expr $Kfc*$fc];		# CONFINED concrete (mander model), maximum stress
set eps1C [expr 2.*$fc1C/$Ec];	# strain at maximum stress 
set fc2C [expr $Kres*$fc1C];		# ultimate stress
set eps2C  [expr 20*$eps1C];		# strain at ultimate stress 
set lambda 0.1;			# ratio between unloading slope at $eps2 and initial slope $Ec
# unconfined concrete
set fc1U  $fc;			# UNCONFINED concrete (todeschini parabolic model), maximum stress
set eps1U -0.003;			# strain at maximum strength of unconfined concrete
set fc2U [expr $Kres*$fc1U];		# ultimate stress
set eps2U -0.01;			# strain at ultimate stress

# tensile-strength properties
set ftC [expr -0.14*$fc1C];		# tensile strength +tension
set ftU [expr -0.14*$fc1U];		# tensile strength +tension
set Ets [expr $ftU/0.002];		# tension softening stiffness

# set up library of materials
if {  [info exists imat ] != 1} {set imat 0};		# set value only if it has not been defined previously.
set IDconcCore 1
set IDconcCover 2
uniaxialMaterial Concrete02 $IDconcCore $fc1C $eps1C $fc2C $eps2C $lambda $ftC $Ets;	# Core concrete (confined)
uniaxialMaterial Concrete02 $IDconcCover $fc1U $eps1U $fc2U $eps2U $lambda $ftU $Ets;	# Cover concrete (unconfined)

# -----------------------------------------------------------------------------------------------------# REINFORCING STEEL parameters
#
set Fy 460E6;		# STEEL yield stress
set Es 200E9;		# modulus of steel
set Bs 0.01;			# strain-hardening ratio 
set R0 18;			# control the transition from elastic to plastic branches
set cR1 0.925;			# control the transition from elastic to plastic branches
set cR2 0.15;			# control the transition from elastic to plastic branches

set IDSteel 3
uniaxialMaterial Steel02 $IDSteel  $Fy $Es $Bs $R0 $cR1 $cR2

# FIBER SECTION properties 
# Column section geometry:
set cover 0.05;	# rectangular-RC-Column cover
set numBarsTopCol 8;		# number of longitudinal-reinforcement bars on top layer
set numBarsBotCol 8;		# number of longitudinal-reinforcement bars on bottom layer
set numBarsIntCol 6;		# TOTAL number of reinforcing bars on the intermediate layers
set barAreaTopCol 0.0014516;	# longitudinal-reinforcement bar area
set barAreaBotCol $barAreaTopCol;	# longitudinal-reinforcement bar area
set barAreaIntCol $barAreaTopCol;	# longitudinal-reinforcement bar area

set numBarsTopBeam 6;		# number of longitudinal-reinforcement bars on top layer
set numBarsBotBeam 6;		# number of longitudinal-reinforcement bars on bottom layer
set numBarsIntBeam 2;		# TOTAL number of reinforcing bars on the intermediate layers
set barAreaTopBeam 0.0014516;	# longitudinal-reinforcement bar area
set barAreaBotBeam $barAreaTopBeam;	# longitudinal-reinforcement bar area
set barAreaIntBeam $barAreaTopBeam;	# longitudinal-reinforcement bar area

set numBarsTopGird 6;		# number of longitudinal-reinforcement bars on top layer
set numBarsBotGird 6;		# number of longitudinal-reinforcement bars on bottom layer
set numBarsIntGird 2;		# TOTAL number of reinforcing bars on the intermediate layers
set barAreaTopGird $barAreaTopBeam;	# longitudinal-reinforcement bar area
set barAreaBotGird $barAreaTopBeam;	# longitudinal-reinforcement bar area
set barAreaIntGird $barAreaTopBeam;	# longitudinal-reinforcement bar area

set nfCoreY 20;		# number of fibers in the core patch in the y direction
set nfCoreZ 20;		# number of fibers in the core patch in the z direction
set nfCoverY 20;		# number of fibers in the cover patches with long sides in the y direction
set nfCoverZ 20;		# number of fibers in the cover patches with long sides in the z direction
# rectangular section with one layer of steel evenly distributed around the perimeter and a confined core.
BuildRCrectSection $ColSecTagFiber $HCol $BCol $cover $cover $IDconcCore  $IDconcCover $IDSteel $numBarsTopCol $barAreaTopCol $numBarsBotCol $barAreaBotCol $numBarsIntCol $barAreaIntCol  $nfCoreY $nfCoreZ $nfCoverY $nfCoverZ
BuildRCrectSection $BeamSecTagFiber $HBeam $BBeam $cover $cover $IDconcCore  $IDconcCover $IDSteel $numBarsTopBeam $barAreaTopBeam $numBarsBotBeam $barAreaBotBeam $numBarsIntBeam $barAreaIntBeam  $nfCoreY $nfCoreZ $nfCoverY $nfCoverZ
BuildRCrectSection $GirdSecTagFiber $HGird $BGird $cover $cover $IDconcCore  $IDconcCover $IDSteel $numBarsTopGird $barAreaTopGird $numBarsBotGird $barAreaBotGird $numBarsIntGird $barAreaIntGird  $nfCoreY $nfCoreZ $nfCoverY $nfCoverZ

# assign torsional Stiffness for 3D Model
uniaxialMaterial Elastic $SecTagTorsion $Ubig
section Aggregator $ColSecTag $SecTagTorsion T -section $ColSecTagFiber
section Aggregator $BeamSecTag $SecTagTorsion T -section $BeamSecTagFiber
section Aggregator $GirdSecTag $SecTagTorsion T -section $GirdSecTagFiber

# define ELEMENTS -------------------------------------------------------
# set up geometric transformations of element
#   separate columns and beams, in case of P-Delta analysis for columns
#   in 3D model, assign vector vecxz
set IDColTransf 1; # all columns
set IDBeamTransf 2; # all beams
set IDGirdTransf 3; # all girders
set ColTransfType Linear ;			# options, Linear PDelta Corotational 

geomTransf Linear $IDColTransf  0 0 1 ; 	# only columns can have PDelta effects (gravity effects)
geomTransf Linear $IDBeamTransf 0 0 1
geomTransf Linear $IDGirdTransf 1 0 0

# Define Beam-Column Elements
set np 5;	# number of Gauss integration points for nonlinear curvature distribution

element nonlinearBeamColumn 101 100000 100 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 102 001 101 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 103 010 110 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 104 011 111 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 1001 100 101 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 1002 101 111 $np $BeamSecTag $IDBeamTransf;
element nonlinearBeamColumn 1003 111 110 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 1004 110 100 $np $BeamSecTag $IDBeamTransf;

element nonlinearBeamColumn 201 100 200 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 202 101 201 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 203 110 210 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 204 111 211 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 2001 200 201 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 2002 201 211 $np $BeamSecTag $IDBeamTransf;
element nonlinearBeamColumn 2003 211 210 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 2004 210 200 $np $BeamSecTag $IDBeamTransf;

element nonlinearBeamColumn 301 200 300 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 302 201 301 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 303 210 310 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 304 211 311 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 3001 300 301 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 3002 301 311 $np $BeamSecTag $IDBeamTransf;
element nonlinearBeamColumn 3003 311 310 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 3004 310 300 $np $BeamSecTag $IDBeamTransf;

element nonlinearBeamColumn 401 300 400 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 402 301 401 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 403 310 410 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 404 311 411 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 4001 400 401 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 4002 401 411 $np $BeamSecTag $IDBeamTransf;
element nonlinearBeamColumn 4003 411 410 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 4004 410 400 $np $BeamSecTag $IDBeamTransf;

element nonlinearBeamColumn 501 400 500 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 502 401 501 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 503 410 510 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 504 411 511 $np $ColSecTag $IDColTransf;
element nonlinearBeamColumn 5001 500 501 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 5002 501 511 $np $BeamSecTag $IDBeamTransf;
element nonlinearBeamColumn 5003 511 510 $np $GirdSecTag $IDGirdTransf
element nonlinearBeamColumn 5004 510 500 $np $BeamSecTag $IDBeamTransf;

# frame 1
set Mmid [expr 7800*0.2*$LBeam*$LGird/4];
set Mtop [expr 7800*0.2*$LBeam*$LGird/4];
mass 100 $Mmid 0 $Mmid 0. 0. 0.;		# level 2
mass 101 $Mmid 0 $Mmid 0. 0. 0.;
mass 110 $Mmid 0 $Mmid 0. 0. 0.;
mass 111 $Mmid 0 $Mmid 0. 0. 0.;

mass 200 $Mmid 0 $Mmid 0. 0. 0.;
mass 201 $Mmid 0 $Mmid 0. 0. 0.;
mass 210 $Mmid 0 $Mmid 0. 0. 0.;
mass 211 $Mmid 0 $Mmid 0. 0. 0.;

mass 300 $Mtop 0 $Mtop 0. 0. 0.;
mass 301 $Mtop 0 $Mtop 0. 0. 0.;
mass 310 $Mtop 0 $Mtop 0. 0. 0.;
mass 311 $Mtop 0 $Mtop 0. 0. 0.;

mass 400 $Mtop 0 $Mtop 0. 0. 0.;
mass 401 $Mtop 0 $Mtop 0. 0. 0.;
mass 410 $Mtop 0 $Mtop 0. 0. 0.;
mass 411 $Mtop 0 $Mtop 0. 0. 0.;

mass 500 $Mtop 0 $Mtop 0. 0. 0.;
mass 501 $Mtop 0 $Mtop 0. 0. 0.;
mass 510 $Mtop 0 $Mtop 0. 0. 0.;
mass 511 $Mtop 0 $Mtop 0. 0. 0.;

puts "Model Built"

set Dmax [expr 0.03*$LBuilding ];	# maximum displacement of pushover. push to 10% drift.
set Dincr [expr $Dmax/100 ];	# displacement increment. you want this to be small, but not too small to slow analysis

# -- STATIC PUSHOVER/CYCLIC ANALYSIS
# create load pattern for lateral pushover load coefficient when using linear load pattern
# need to apply lateral load only to the master nodes of the rigid diaphragm at each floor

# Set up parameters that are particular to the model for displacement control
set IDctrlNode 500;		# node where displacement is read for displacement control
set IDctrlDOF 1;			# degree of freedom of displacement read for displacement control

set P41_51 0.9;
set P31_51 0.8;
set P21_51 0.7;


pattern Plain 200 Linear {;			
	load 5001 1.0 0. 0. 0. 0. 0.
	load 4001 $P41_51 0. 0. 0. 0. 0.
	load 3001 $P31_51 0. 0. 0. 0. 0.
	load 2001 $P21_51 0. 0. 0. 0. 0.
}

# Define RECORDERS -------------------------------------------------------------
recorder Node -file DFree.out -time -node $IDctrlNode -dof 1 disp;			# displacements of free node


#  ---------------------------------    perform Static Pushover Analysis
# ----------- set up analysis parameters

variable constraintsTypeStatic Plain;		# default;
if {  [info exists RigidDiaphragm] == 1} {
	if {$RigidDiaphragm=="ON"} {
		variable constraintsTypeStatic Lagrange;	#     for large model, try Transformation
	};	# if rigid diaphragm is on
};	# if rigid diaphragm exists
constraints $constraintsTypeStatic
set numbererTypeStatic RCM
numberer $numbererTypeStatic 
set systemTypeStatic BandGeneral;		# try UmfPack for large model
system $systemTypeStatic 
variable TolStatic 1.e-3;                        # Convergence Test: tolerance
variable maxNumIterStatic 6;                # Convergence Test: maximum number of iterations that will be performed before "failure to converge" is returned
variable printFlagStatic 0;                # Convergence Test: flag used to print information on convergence (optional)        # 1: print information on each step; 
variable testTypeStatic EnergyIncr ;	# Convergence-test type
test $testTypeStatic $TolStatic $maxNumIterStatic $printFlagStatic;
# for improved-convergence procedure:
	variable maxNumIterConvergeStatic 2000;	
	variable printFlagConvergeStatic 0;
variable algorithmTypeStatic Newton
algorithm $algorithmTypeStatic;        
integrator DisplacementControl  $IDctrlNode   $IDctrlDOF $Dincr
set analysisTypeStatic Static
analysis $analysisTypeStatic 

set fmt1 "%s Pushover analysis: CtrlNode %.3i, dof %.1i, Disp=%.4f %s";	# format for screen/file output of DONE/PROBLEM analysis
# ----------------------------------------------first analyze command------------------------
set Nsteps [expr int($Dmax/$Dincr)];		# number of pushover analysis steps
set ok [analyze $Nsteps];                		# this will return zero if no convergence problems were encountered
# ----------------------------------------------if convergence failure-------------------------
if {$ok != 0} {  
	# if analysis fails, we try some other stuff, performance is slower inside this loop
	set Dstep 0.0;
	set ok 0
	while {$Dstep <= 1.0 && $ok == 0} {	
		set controlDisp [nodeDisp $IDctrlNode $IDctrlDOF ]
		set Dstep [expr $controlDisp/$Dmax]
		set ok [analyze 1];                		# this will return zero if no convergence problems were encountered
		if {$ok != 0} {;				# reduce step size if still fails to converge
			set Nk 4;			# reduce step size
			set DincrReduced [expr $Dincr/$Nk];
			integrator DisplacementControl  $IDctrlNode $IDctrlDOF $DincrReduced
			for {set ik 1} {$ik <=$Nk} {incr ik 1} {
				set ok [analyze 1];                		# this will return zero if no convergence problems were encountered
				if {$ok != 0} {  
					# if analysis fails, we try some other stuff
					# performance is slower inside this loop	global maxNumIterStatic;	    # max no. of iterations performed before "failure to converge" is ret'd
					puts "Trying Newton with Initial Tangent .."
					test NormDispIncr   $TolStatic 2000 0
					algorithm Newton -initial
					set ok [analyze 1]
					test $testTypeStatic $TolStatic      $maxNumIterStatic    0
					algorithm $algorithmTypeStatic
				}
				if {$ok != 0} {
					puts "Trying Broyden .."
					algorithm Broyden 8
					set ok [analyze 1 ]
					algorithm $algorithmTypeStatic
				}
				if {$ok != 0} {
					puts "Trying NewtonWithLineSearch .."
					algorithm NewtonLineSearch 0.8 
					set ok [analyze 1]
					algorithm $algorithmTypeStatic
				}
				if {$ok != 0} {;				# stop if still fails to converge
					puts [format $fmt1 "PROBLEM" $IDctrlNode $IDctrlDOF [nodeDisp $IDctrlNode $IDctrlDOF] "m"]
					return -1
				}; # end if
			}; # end for
			integrator DisplacementControl  $IDctrlNode $IDctrlDOF $Dincr;	# bring back to original increment
		}; # end if
	};	# end while loop
};      # end if ok !0
# -----------------------------------------------------------------------------------------------------
