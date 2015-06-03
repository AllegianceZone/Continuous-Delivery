use File::Path qw(remove_tree);
use Data::Dumper;
my $azbp = $ARGV[0];
remove_tree("$azbp\\Test\\PCore005b", {verbose => 1,error => \my $err_list,});
print Dumper($err_list);
