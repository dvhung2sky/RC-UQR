# units: kip, inch, sec
wipe;					# clear memory of all past model definitions
file mkdir Data; 				# create data directory
model BasicBuilder -ndm 2 -ndf 3;		# Define the model builder, ndm=#dimension, ndf=#dofs


# define GEOMETRY -------------------------------------------------------------
set LCol 3.5; 		# column length
set LBeam 8.0;		# beam length
# define section geometry
set HCol 0.6; 		# Column Depth
set BCol 0.6;		# Column Width
set HBeam 0.8;		# Beam Depth
set BBeam 0.6;		# Beam Width


# calculated parameters
set g 9.81;			# g.
# calculated geometry parameters
set ACol [expr $BCol*$HCol];					# cross-sectional area
set ABeam [expr $BBeam*$HBeam];
set IzCol [expr 1./12.*$BCol*pow($HCol,3)]; 			# Column moment of inertia
set IzBeam [expr 1./12.*$BBeam*pow($HBeam,3)]; 		# Beam moment of inertia

# nodal coordinates:
node 1 0 0;			# node#, X, Y
node 2 $LBeam 0
node 11 0 $LCol 		
node 12 $LBeam $LCol 		
node 21 0 [expr $LCol*2] 		
node 22 $LBeam [expr $LCol*2]
node 31 0 [expr $LCol*3] 		
node 32 $LBeam [expr $LCol*3]


# Single point constraints -- Boundary Conditions
fix 1 1 1 1; 			# node DX DY RZ
fix 2 1 1 1; 			# node DX DY RZ


# Define ELEMENTS & SECTIONS -------------------------------------------------------------
set ColSecTag 1;			# assign a tag number to the column section	
set BeamSecTag 2;			# assign a tag number to the beam section	
# define section geometry
set coverCol 0.06;			# Column cover to reinforcing steel NA.
set numBarsTop 5;			# number of longitudinal-reinforcement bars in each side of column section. (symmetric top & bot)
set barAreaTop 0.0014516 ;		# area of longitudinal-reinforcement bars
set numBarsBot 5;			# number of longitudinal-reinforcement bars in each side of column section. (symmetric top & bot)
set barAreaBot $barAreaTop ;		# area of longitudinal-reinforcement bars

set coverBeam $coverCol;			# Column cover to reinforcing steel NA.
set numBarsTop_beam 4;			# number of longitudinal-reinforcement bars in each side of column section. (symmetric top & bot)
set barAreaTop_beam 0.0014516 ;		# area of longitudinal-reinforcement bars
set numBarsBot_beam 6;			# number of longitudinal-reinforcement bars in each side of column section. (symmetric top & bot)
set barAreaBot_beam $barAreaTop_beam ;		# area of longitudinal-reinforcement bars

# MATERIAL parameters -------------------------------------------------------------------
set IDconcU 1; 			# material ID tag -- unconfined cover concrete
set IDreinf 2; 				# material ID tag -- reinforcement
# nominal concrete compressive strength
set fc -24.5E6; 				# CONCRETE Compressive Strength (+Tension, -Compression)
set Ec 24.8E9; 		# Concrete Elastic Modulus (the term in sqr root needs to be in psi
# unconfined concrete
set fc1U 		$fc;			# UNCONFINED concrete (todeschini parabolic model), maximum stress
set eps1U	-0.003;			# strain at maximum strength of unconfined concrete
set fc2U 		[expr 0.2*$fc1U];		# ultimate stress
set eps2U	-0.01;			# strain at ultimate stress
set lambda 0.1;				# ratio between unloading slope at $eps2 and initial slope $Ec
# tensile-strength properties
set ftU [expr -0.14*$fc1U];			# tensile strength +tension
set Ets [expr $ftU/0.002];			# tension softening stiffness
# -----------
set Fy [expr 66.8*6894757.28];				# STEEL yield stress
set Es [expr 29000.0*6894757.28];				# modulus of steel
set Bs 0.01;				# strain-hardening ratio 
set R0 18;				# control the transition from elastic to plastic branches
set cR1 0.925;				# control the transition from elastic to plastic branches
set cR2 0.15;				# control the transition from elastic to plastic branches
uniaxialMaterial Concrete02 $IDconcU $fc1U $eps1U $fc2U $eps2U $lambda $ftU $Ets;	# build cover concrete (unconfined)
uniaxialMaterial Steel02 $IDreinf $Fy $Es $Bs $R0 $cR1 $cR2;				# build reinforcement material

# RC section: 
   set coverY [expr $HCol/2.0];	# The distance from the section z-axis to the edge of the cover concrete -- outer edge of cover concrete
   set coverZ [expr $BCol/2.0];	# The distance from the section y-axis to the edge of the cover concrete -- outer edge of cover concrete
   set coreY [expr $coverY-$coverCol]
   set coreZ [expr $coverZ-$coverCol]
   set nfY 16;			# number of fibers for concrete in y-direction
   set nfZ 4;			# number of fibers for concrete in z-direction
   section fiberSec $ColSecTag   {;	# Define the fiber section
	patch quadr $IDconcU $nfZ $nfY -$coverY $coverZ -$coverY -$coverZ $coverY -$coverZ $coverY $coverZ; 	# Define the concrete patch
	layer straight $IDreinf $numBarsTop $barAreaTop -$coreY $coreZ -$coreY -$coreZ;	# top layer reinfocement
	layer straight $IDreinf $numBarsBot $barAreaBot  $coreY $coreZ  $coreY -$coreZ;	# bottom layer reinforcement
    };	# end of fibersection definition

# RC section: 
   set coverY_beam [expr $HBeam/2.0];	# The distance from the section z-axis to the edge of the cover concrete -- outer edge of cover concrete
   set coverZ_beam [expr $BBeam/2.0];	# The distance from the section y-axis to the edge of the cover concrete -- outer edge of cover concrete
   set coreY_beam [expr $coverY_beam-$coverBeam]
   set coreZ_beam [expr $coverZ_beam-$coverBeam]
   set nfY_beam 16;			# number of fibers for concrete in y-direction
   set nfZ_beam 4;			# number of fibers for concrete in z-direction
   section fiberSec $BeamSecTag   {;	# Define the fiber section
	patch quadr $IDconcU $nfZ_beam $nfY_beam -$coverY_beam $coverZ_beam -$coverY_beam -$coverZ_beam $coverY_beam -$coverZ_beam $coverY_beam $coverZ_beam; 	# Define the concrete patch
	layer straight $IDreinf $numBarsTop_beam $barAreaTop_beam -$coreY_beam $coreZ_beam -$coreY_beam -$coreZ_beam;	# top layer reinfocement
	layer straight $IDreinf $numBarsBot_beam $barAreaBot_beam  $coreY_beam $coreZ_beam  $coreY_beam -$coreZ_beam;	# bottom layer reinforcement
    };	# end of fibersection definition




# define geometric transformation: performs a linear geometric transformation of beam stiffness and resisting force from the basic system to the global-coordinate system
set ColTransfTag 1; 			# associate a tag to column transformation
set BeamTransfTag 2; 			# associate a tag to beam transformation (good practice to keep col and beam separate)

geomTransf Linear $ColTransfTag  ; 
geomTransf Linear $BeamTransfTag  ; 		

# element connectivity:
set numIntgrPts 8;								# number of integration points for force-based element
element nonlinearBeamColumn 1 1 11 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
element nonlinearBeamColumn 2 2 12 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
element nonlinearBeamColumn 3 11 12 $numIntgrPts $BeamSecTag $BeamTransfTag;	# self-explanatory when using variables

element nonlinearBeamColumn 11 11  21 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
element nonlinearBeamColumn 12 12  22 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
element nonlinearBeamColumn 13 21  22 $numIntgrPts $BeamSecTag $BeamTransfTag;	# self-explanatory when using variables

element nonlinearBeamColumn 21 21  31 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
element nonlinearBeamColumn 22 22  32 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
element nonlinearBeamColumn 23 31  32 $numIntgrPts $BeamSecTag $BeamTransfTag;	# self-explanatory when using variables


puts "Model Built"

# STATIC PUSHOVER ANALYSIS --------------------------------------------------------------------------------------------------
#
# we need to set up parameters that are particular to the model.
set IDctrlNode 31;			# node where displacement is read for displacement control
set IDctrlDOF 1;			# degree of freedom of displacement read for displacement contro
set Dmax [expr 0.05*$LCol];		# maximum displacement of pushover. push to 10% drift.
set Dincr [expr $Dmax/100];		# displacement increment for pushover. you want this to be very small, but not too small to slow down the analysis

set P21_31 0.5;
# create load pattern for lateral pushover load
pattern Plain 200 Linear {;			# define load pattern -- generalized
	load 31 1.0 0.0 0.0;	# define lateral load in static lateral analysis
	load 21 $P21_31 0.0 0.0;	# define lateral load in static lateral analysis
}

# Define RECORDERS -------------------------------------------------------------
recorder Node -file DFree.out -time -node $IDctrlNode -dof 1 	disp;		# displacements of free nodes


constraints Plain;		
numberer Plain
system BandGeneral

set Tol 1.e-3;                        # Convergence Test: tolerance
set maxNumIter 6;                # Convergence Test: maximum numberg of iterations that will be performed before "failure to converge" is returned
set printFlag 0;                # Convergence Test: flag used to print information on convergence (optional)        # 1: print information on each step; 
set TestType EnergyIncr ;	# Convergence-test type
test $TestType $Tol $maxNumIter $printFlag;

set algorithmType Newton
algorithm $algorithmType;        
integrator DisplacementControl  $IDctrlNode   $IDctrlDOF $Dincr
analysis Static

#  ---------------------------------    perform Static Pushover Analysis
set Nsteps [expr int($Dmax/$Dincr)];        # number of pushover analysis steps
set ok [analyze $Nsteps];                # this will return zero if no convergence problems were encountered

# ---------------------------------- in case of convergence problems
if {$ok != 0} {      
# change some analysis parameters to achieve convergence
# performance is slower inside this loop
	set ok 0;
	set controlDisp 0.0;		# start from zero
	set D0 0.0;		# start from zero
	set Dstep [expr ($controlDisp-$D0)/($Dmax-$D0)]
	while {$Dstep < 1.0 && $ok == 0} {	
		set controlDisp [nodeDisp $IDctrlNode $IDctrlDOF ]
		set Dstep [expr ($controlDisp-$D0)/($Dmax-$D0)]
		set ok [analyze 1 ]
		if {$ok != 0} {
			puts "Trying Newton with Initial Tangent .."
			test NormDispIncr   $Tol 2000  0
			algorithm Newton -initial
			set ok [analyze 1 ]
			test $TestType $Tol $maxNumIter  0
			algorithm $algorithmType
		}
		if {$ok != 0} {
			puts "Trying Broyden .."
			algorithm Broyden 8
			set ok [analyze 1 ]
			algorithm $algorithmType
		}
		if {$ok != 0} {
			puts "Trying NewtonWithLineSearch .."
			algorithm NewtonLineSearch .8
			set ok [analyze 1 ]
			algorithm $algorithmType
		}
	}
	};      # end if ok !0

puts "DonePushover"


