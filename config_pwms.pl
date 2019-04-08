use strict;
use warnings;
if(@ARGV != 1) {die "Usage: <memefiles> \n"}
my $list = $ARGV[0];
#@files = glob($ARGV[0]);
#print OUT @files, "\n";
#import os
open(F, $list);
open Output_list, ">motifs_list.txt" or die;
open Output_meme, ">RBP_PWMs.meme" or die;
my $dirinput = "/Users/jiwang/Motif_analysis/mRNA_decay/RBP_Entiredata/pwms/"; 

print Output_meme "MEME version 4.4\n";
print Output_meme "\n";
print Output_meme "ALPHABET= ACGT\n";
print Output_meme "\n";
print Output_meme "strands: + -\n";
print Output_meme "\n";
print Output_meme "Background letter frequencies (from uniform background):\n";
print Output_meme "A 0.25000 C 0.25000 G 0.25000 T 0.25000\n";

while(my $meme = <F>)
{
	chomp $meme;
	my $input = join('', $dirinput, $meme, ".txt");
	#print $input, "\n"; 
	
	if ( -z $input) {	
		print $meme,  ".txt is empty!\n";
		
	}else{
		# save motif in the list
		print Output_list $meme, "\n";
		
		# save pwd in the .meme file
		print Output_meme "\n";
		print Output_meme "MOTIF $meme\n";
		print Output_meme "\n";
		
		## open the motif file and count number of lines
		open (Motif, $input);
		my $ll = 0;
		while(my $line = <Motif>)
		{	
			if($line eq ""){
				print "line is emplty";
				next;
			}else{
				$ll = $ll + 1 ;
			}
		}
		close(Motif);
		
		print Output_meme "letter-probability matrix: alength= 4 w= ", $ll-1, " nsites= 20 E= 0 \n";
		open (Motif, $input);
		while(my $line = <Motif>)
		{	
			if($line eq ""){
				print "line is emplty";
				next;
			}else{
				my @prob = split('\t', $line);
				my $first = $prob[0];
				#print $first, "\n";
				if($first eq "Pos"){
					next;
				}else{
					print Output_meme "$prob[1]\t$prob[2]\t$prob[3]\t$prob[4]\n"; 
				}
			}
		}
		close(Motif);
		
	}
	
}

close(Output_list);
close(Output_meme);