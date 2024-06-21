# units: kip, inch, sec
wipe;					# clear memory of all past model definitions
file mkdir Data; 				# create data directory
model BasicBuilder -ndm 2 -ndf 3;		# Define the model builder, ndm=#dimension, ndf=#dofs


# define GEOMETRY -------------------------------------------------------------
set LCol 8; 		# column length
set Weight 8896443.2; 		# superstructure weight
# define section geometry
set HCol 1.5; 		# Column Depth
set BCol 1.2;		# Column Width

# calculated parameters
set PCol $Weight; 		# nodal dead-load weight per column
set g 9.81;			# g.
set Mass [expr $PCol/$g];		# nodal mass
# calculated geometry parameters
set ACol [expr $BCol*$HCol];					# cross-sectional area
set IzCol [expr 1./12.*$BCol*pow($HCol,3)]; 			# Column moment of inertia

# nodal coordinates:
node 1 0 0;			# node#, X, Y
node 2 0 $LCol 		

# Single point constraints -- Boundary Conditions
fix 1 1 1 1; 			# node DX DY RZ

# nodal masses:
mass 2 $Mass  1e-9 0.;		# node#, Mx My Mz, Mass=Weight/g, neglect rotational inertia at nodes

# Define ELEMENTS & SECTIONS -------------------------------------------------------------
set ColSecTag 1;			# assign a tag number to the column section	
# define section geometry
set coverCol 0.06;			# Column cover to reinforcing steel NA.
set numBarsTop 5;			# number of longitudinal-reinforcement bars in each side of column section. (symmetric top & bot)
set barAreaTop 0.0014516 ;		# area of longitudinal-reinforcement bars

set numBarsBot 5;			# number of longitudinal-reinforcement bars in each side of column section. (symmetric top & bot)
set barAreaBot $barAreaTop ;		# area of longitudinal-reinforcement bars


# MATERIAL parameters -------------------------------------------------------------------
set IDconcU 1; 			# material ID tag -- unconfined cover concrete
set IDreinf 2; 				# material ID tag -- reinforcement
# nominal concrete compressive strength
set fc -27E6; 				# CONCRETE Compressive Strength (+Tension, -Compression)
set Ec 25E9; 		# Concrete Elastic Modulus (the term in sqr root needs to be in psi
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
set Fy 460E6;				# STEEL yield stress
set Es 200E9;				# modulus of steel
set Bs 0.01;				# strain-hardening ratio 
set R0 18;				# control the transition from eclastic to plastic branches
set cR1 0.925;				# control the transition from elastic to plastic branches
set cR2 0.15;				# control the transition from elastic to plastic branches
uniaxialMaterial Concrete02 $IDconcU $fc1U $eps1U $fc2U $eps2U $lambda $ftU $Ets;	# build cover concrete (unconfined)
uniaxialMaterial Steel02 $IDreinf $Fy $Es $Bs $R0 $cR1 $cR2;				# build reinforcement material

# RC section: 
   set coverY [expr $HCol/2.0];	# The distance from the section z-axis to the edge of the cover concrete -- outer edge of cover concrete
   set coverZ [expr $BCol/2.0];	# The distance from the section y-axis to the edge of the cover concrete -- outer edge of cover concrete
   set coreY [expr $coverY-$coverCol]
   set coreZ [expr $coverZ-$coverCol]
   set nfY 10;			# number of fibers for concrete in y-direction
   set nfZ 10;			# number of fibers for concrete in z-direction
   section fiberSec $ColSecTag   {;	# Define the fiber section
	patch quadr $IDconcU $nfZ $nfY -$coverY $coverZ -$coverY -$coverZ $coverY -$coverZ $coverY $coverZ; 	# Define the concrete patch
	layer straight $IDreinf $numBarsTop $barAreaTop -$coreY $coreZ -$coreY -$coreZ;	# top layer reinfocement
	layer straight $IDreinf 2 $barAreaTop            [expr -$coreY/2]      $coreZ   [expr -$coreY/2]      -$coreZ;	# top layer reinfocement
	layer straight $IDreinf 2 $barAreaTop            0      $coreZ  0      -$coreZ;	# top layer reinfocement	
	layer straight $IDreinf 2 $barAreaTop            [expr $coreY/2]      $coreZ   [expr $coreY/2]      -$coreZ;	# top layer reinfocement
	layer straight $IDreinf $numBarsBot $barAreaBot  $coreY $coreZ  $coreY -$coreZ;	# bottom layer reinforcement
    };	# end of fibersection definition

# define geometric transformation: performs a linear geometric transformation of beam stiffness and resisting force from the basic system to the global-coordinate system
set ColTransfTag 1; 			# associate a tag to column transformation
geomTransf Linear $ColTransfTag  ; 	

# element connectivity:
set numIntgrPts 5;								# number of integration points for force-based element
element nonlinearBeamColumn 1 1 2 $numIntgrPts $ColSecTag $ColTransfTag;	# self-explanatory when using variables
# element elasticBeamColumn 1 1 2 $ACol $Ec $IzCol $ColTransfTag;			# self-explanatory when using variables


puts "Model Built"

# STATIC PUSHOVER ANALYSIS --------------------------------------------------------------------------------------------------
#
# we need to set up parameters that are particular to the model.
set IDctrlNode 2;			# node where displacement is read for displacement control
set IDctrlDOF 1;			# degree of freedom of displacement read for displacement contro
set Dmax [expr 0.01*$LCol];		# maximum displacement of pushover. push to 10% drift.
set Dincr [expr 0.0001*$LCol];		# displacement increment for pushover. you want this to be very small, but not too small to slow down the analysis

# create load pattern for lateral pushover load
set Hload $Weight;				# define the lateral load as a proportion of the weight so that the pseudo time equals the lateral-load coefficient when using linear load pattern
pattern Plain 200 Linear {;			# define load pattern -- generalized
	load 2 1.0 0.0 0.0;	# define lateral load in static lateral analysis
}

# Define RECORDERS -------------------------------------------------------------
recorder Node -file DFree.out -time -node 2 -dof 1 	disp;		# displacements of free nodes


constraints Plain;		
numberer Plain
system BandGeneral

set Tol 1.e-8;                        # Convergence Test: tolerance
set maxNumIter 6;                # Convergence Test: maximum number of iterations that will be performed before "failure to converge" is returned
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

