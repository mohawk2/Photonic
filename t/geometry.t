use strict;
use warnings;
use PDL;
use PDL::NiceSlice;
use PDL::Complex;
use Photonic::Geometry::FromB;
use Test::More tests => 32;
my $pi=4*atan2(1,1);

sub agree {    
    my $a=shift;
    my $b=shift//0;
    return (($a-$b)*($a-$b))->sum<=1e-7;
}
    
my $B=zeroes(11,11)->rvals<=5;
my $g=Photonic::Geometry::FromB->new(B=>$B);
my $gl=Photonic::Geometry::FromB->new(B=>$B, L=>pdl(1,1));
ok(defined $g, "Create geometry from B");
ok(agree($g->B,$B), "Recover B");
ok($g->L->ndims==1, "L is a vector");
ok(($g->L->dims)[0]==2, "L is a 2D vector");
ok(($g->L->dims)[0]==2, "L is a 2D vector");
ok(agree(pdl($g->L),pdl(11,11)), "correct L values");
ok(agree(($g->units)->[0], pdl(1,0)) && agree(($g->units)->[1], pdl(0,1)),
   "units"); 
ok($g->npoints==11*11, "npoints");
ok(agree($g->scale,pdl(1,1)), "Default scale");
ok(agree($gl->scale, pdl(1/11,1/11)), "Scale");
ok(agree($g->r->(:,(5),(5)), pdl(5,5)), "Default coordinates of center");
ok(agree($gl->r->(:,(5),(5)), pdl(5/11,5/11)), "Coordinates of center");
ok(agree($g->G->(:,(0),(0)), pdl(0,0)), "Reciprocal vector at corner");
ok(agree($g->G->(:,(5),(5)), pdl(5*2*$pi/11,5*2*$pi/11)),
   "Default reciprocal vector at center");
ok(agree($g->G->(:,(6),(6)), pdl(-5*2*$pi/11,-5*2*$pi/11)),
   "Default reciprocal vector beyond center");
ok(agree($gl->G->(:,(6),(6)), pdl(-5*2*$pi,-5*2*$pi)),
   "Reciprocal vector beyond center");
ok(!$g->has_Direction0, "False Direction0 predicate");
$g->Direction0(pdl(1,0)); #set direction 0
ok($g->has_Direction0, "True Direction0 predicate");
ok(agree($g->GNorm->(:,(0),(0)),pdl(1,0)), "Normalized G=0 reciprocal vector");
ok(agree($g->GNorm->(:,(5),(5)),pdl(1,1)/sqrt(2)),
   "Normalized reciprocal vector at center");
ok(agree($g->GNorm->(:,(0),(0)),pdl(1,0)), "Normalized G=-0 reciprocal vector");
ok(agree($g->mGNorm->(:,(5),(5)),-pdl(1,1)/sqrt(2)),
   "-normalized reciprocal vector at center");
ok(agree($g->GNorm->(:,(0),(0)), $g->pmGNorm->(:,(0),(0),(0)))
    && agree($g->mGNorm->(:,(0),(0)), $g->pmGNorm->(:,(1),(0),(0))),
    "spinor normalized G at corner");
ok(agree($g->GNorm->(:,(5),(5)), $g->pmGNorm->(:,(0),(5),(5)))
    && agree($g->mGNorm->(:,(5),(5)), $g->pmGNorm->(:,(1),(5),(5))),
    "spinor normalized G at center");
ok($g->f==$B->sum/(11*11), "filling fraction");
ok(agree($g->unitPairs->[0], pdl(1,0))
   && agree($g->unitPairs->[1], pdl(1,1)/sqrt(2))
   && agree($g->unitPairs->[2], pdl(0,1)), "unitpairs");
ok(agree($g->CunitPairs->[0]->re, pdl(1,0)/sqrt(2))
   && agree($g->CunitPairs->[0]->im, pdl(0,1)/sqrt(2)),
   "cunitpairs");
ok(agree($g->CCunitPairs->[0]->re, pdl(1,0)/sqrt(2))
   && agree($g->CCunitPairs->[0]->im, -pdl(0,1)/sqrt(2)),
   "ccunitpairs");
ok(agree($g->unitDyads, pdl([1,0,0],[.5,1,.5],[0,0,1])), "unitDyads");
ok(agree(lu_backsub(@{$g->unitDyadsLU}, $g->unitDyads->transpose),
	 identity(3)), "unitDyadsLU");
ok(agree($g->Vec2LC_G(zeroes(11,11)->ndcoords->r2C)->re,
	 (zeroes(11,11)->ndcoords*$g->GNorm)->sumover),
   "Vec2LC");
ok(agree($g->LC2Vec_G(ones(11,11)->r2C)->re, $g->GNorm), "LC2Vec_G");