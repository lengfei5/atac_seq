#!/usr/bin/perl -w
## usage:
# perl fimoParserToMatrixCountOc2.pl -fimo name_file > output_file
use Getopt::Long;
use FileHandle;
use Data::Dumper;
use IO::Handle;

$\="\n";
$,="\t";

$fimo="";

GetOptions(
	"fimo=s"		=> \$fimo,
);

my %hash;
my %found;

open(FIMO, $fimo) || die "cannot open fimo output file";
while(<FIMO>)
{
    #my $n = $fp->input_line_number();
    #print $n, "\n";
    #print $.;
    #next if $.==1;
    next if/^#/;
    chomp;
    my @line = split(/\t/);
    #print @line, "\n";
    my $motif = $line[0];
    my $region = $line[1];
    $hash{$motif}{$region}++;	
    $found{$region}++;
}

#print Dumper(%hash);
my @sets = sort keys %found;
#print "test";
#print q{NAME};
#print join(q{ }, q{NAME}, @sets), qq{\n};
print join(q{ }, q{NAME}, @sets);
foreach my $k (sort keys %hash) {
    my @data;
    foreach my $l (@sets) {
        if (defined $hash{$k}{$l}) {
            push @data, $hash{$k}{$l};
        } else {
            push @data, q{0};
        }
    }
    print join(q{ }, $k, @data); #, qq{\n}
}
