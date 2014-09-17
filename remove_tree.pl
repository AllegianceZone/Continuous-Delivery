use File::Path qw(remove_tree);
use Data::Dumper;

remove_tree("C:\\build\\Test\\PCore005b", {verbose => 1,error => \my $err_list,});
print Dumper($err_list);