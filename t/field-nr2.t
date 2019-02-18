use strict;
use warnings;
use PDL;
use PDL::NiceSlice;
use PDL::Complex;
use Photonic::Geometry::FromB;
use Photonic::LE::NR2::AllH;
use Photonic::LE::NR2::Field;

use Machine::Epsilon;
use List::Util;

use Test::More tests => 2;

#my $pi=4*atan2(1,1);

sub Cagree {    
    my $a=shift;
    my $b=shift//0;
    return (($a-$b)->Cabs2)->sum<=1e-7;
}
sub Cdif {    
    my $a=shift;
    my $b=shift//0;
    return (($a-$b)->Cabs2)->sum;
}

my $ea=1+2*i;
my $eb=3+4*i;
#Check haydock coefficients for simple 1D system
my $B=zeroes(11)->xvals<5; #1D system
my $gl=Photonic::Geometry::FromB->new(B=>$B, Direction0=>pdl([1])); #long
my $nr=Photonic::LE::NR2::AllH->new(geometry=>$gl, nh=>10, keepStates=>1);
my $flo=Photonic::LE::NR2::Field->new(nr=>$nr, nh=>10);
my $flv=$flo->evaluate($ea, $eb);
my $fla=1/$ea;
my $flb=1/$eb;
my $fproml=$fla*(1-$gl->f)+$flb*($gl->f);
($fla, $flb)=map {$_/$fproml} ($fla, $flb);
my $flx=pdl([$fla*(1-$B)+$flb*$B])->complex->mv(1,-1);
ok(Cagree($flv, $flx), "1D long field");

#View 2D from 1D superlattice.
my $Bt=zeroes(1,11)->yvals<5; #2D flat system
my $gt=Photonic::Geometry::FromB->new(B=>$Bt, Direction0=>pdl([1,0])); #trans
my $nt=Photonic::LE::NR2::AllH->new(geometry=>$gt, nh=>10, keepStates=>1);
my $fto=Photonic::LE::NR2::Field->new(geometry=>$gt, nr=>$nt, nh=>10);
my $ftv=$fto->evaluate($ea, $eb);
my $ftx=pdl(r2C(1), r2C(0))->complex;
ok(Cagree($ftv, $ftx), "1D trans field");