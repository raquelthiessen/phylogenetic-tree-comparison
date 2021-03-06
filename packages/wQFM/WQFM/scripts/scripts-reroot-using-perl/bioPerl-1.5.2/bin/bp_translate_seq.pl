#!/lusr/perl5.8/bin/perl -w

eval 'exec /lusr/perl5.8/bin/perl -w -S $0 ${1+"$@"}'
    if 0; # not running under some shell
use strict;
# $Id: translate_seq.PLS,v 1.7 2006/07/04 22:23:29 mauricio Exp $

=head1 NAME

translate_seq - translates a sequence

=head1 SYNOPSIS

translate_seq E<lt> cdna_cds.fa E<gt> protein.fa

=head1 DESCRIPTION 

The script will translate one fasta file (on stdin) to protein on stdout

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
of the bugs and their resolution. Bug reports can be submitted via
email or the web:

  http://bugzilla.open-bio.org/

=head1 AUTHOR

  Ewan Birney E<lt>birney@ebi.ac.ukE<gt>

=cut

use Bio::SeqIO;
use Getopt::Long;

my ($format) = 'fasta';

GetOptions(
	   'format:s'  => \$format,
	   );

my $oformat = 'fasta';

# this implicity uses the <> file stream
my $seqin = Bio::SeqIO->new( -format => $format, -file => shift); 
my $seqout = Bio::SeqIO->new( -format => $oformat, -file => ">-" );


while( (my $seq = $seqin->next_seq()) ) {
	my $pseq = $seq->translate();
	$seqout->write_seq($pseq);
}

__END__
