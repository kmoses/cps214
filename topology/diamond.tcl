#Create a simulator object
set ns [new Simulator]
source tb_compat.tcl

#Router Diamond Topology
for {set i 1} {$i <= 4} {incr i} {
	set r($i) [$ns node]
}
set link1 [$ns duplex-link $r(1) $r(2) 10Mb 10ms DropTail]
set link2 [$ns duplex-link $r(1) $r(4) 10Mb 10ms DropTail]
set link3 [$ns duplex-link $r(3) $r(2) 10Mb 10ms DropTail]
set link4 [$ns duplex-link $r(3) $r(4) 10Mb 10ms DropTail]

#One Ubuntu System per Router
for {set i 1} {$i <= 4} {incr i} {
	set pc($i) [$ns node]
	#$ns duplex-link $r($i) $pc($i) 100Mb 2ms DropTail
	set lan($i) [$ns make-lan "$r($i)  $pc($i)" 100Mb 0ms]
	tb-set-node-os $pc($i) UBUNTU11-64-STD
}

#Routing
$ns rtproto Manual
#PC Routes
for {set i 1} {$i <= 4} {incr i} {
	for {set j 1} {$j <=4} {incr j} {
		#Avoids creating a route to itself or directly connected nodes
		if {$i != $j} {
			#$pc($i) add-route $pc($j) $r($i)
			#$pc($i) add-route $r($j) $r($i)
			$pc($i) add-route $lan($j) $r($i)
		}
	}
}

#Router Routes!
$r(1) add-route $lan(2) $r(2)
$r(1) add-route $lan(3) $r(2)
$r(1) add-route $lan(4) $r(4)

$r(2) add-route $lan(1) $r(1)
$r(2) add-route $lan(3) $r(3)
$r(2) add-route $lan(4) $r(3)

$r(3) add-route $lan(1) $r(2)
$r(3) add-route $lan(2) $r(2)
$r(3) add-route $lan(4) $r(4)

$r(4) add-route $lan(1) $r(1)
$r(4) add-route $lan(2) $r(3)
$r(4) add-route $lan(3) $r(3)


#Run the simulation
$ns run
