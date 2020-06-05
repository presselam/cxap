#! /usr/bin/env perl

use 5.020;
use warnings;
use autodie;

use Getopt::Long;

use Toolkit;

my %opts = ( wager => 40, );
if ( !GetOptions( \%opts, 'wager=i', 'total=i', 'eligible=i', 'commit' ) ) {
  die("Invalid incantation\n");
}

main();
exit(0);

sub main {

  my @table = ( [qw( players eligible pot stake )] );
  my $pot   = $opts{'total'} * $opts{'wager'};
  my $first = 2;
  my $last = 2;

  my $value =  sprintf( '%02f', ( $pot * 0.85 ) / $opts{'eligible'} );
  my $goal =  sprintf( '%02f', ( $pot * 0.85 ) / $opts{'wager'} );

  foreach my $elig ( reverse 1 .. $opts{'total'} ) {
    my $stake = sprintf( '%.04f', ( $pot * 0.85 ) / $elig );

    my @row = ( $opts{'total'}, $elig, $pot, $stake );
    if ( $opts{'eligible'} == $elig ) {
      @row = map { yellow($_) } @row;
    }

    if( $value < $opts{'wager'} ){
    if ($first) {
      push( @table, [@row] );
      $first--;
      if ( $first == 0 ) {
        push( @table, [ ( '...', '...', '...', '...' ) ] );
      }
    }
    }

    my $delta = abs( $opts{'eligible'} - $elig );
    if ( $delta <= 5 ) {
      if( $stake > $opts{'wager'} ){
      @row = map { green($_) } @row;
      }
      push( @table, [@row] );
      next;
    }

    $delta = abs( $goal-$elig );
    if( $value < $opts{'wager'} ){
      if( $delta <=2 ){
      if ( $last ) {
        push( @table, [ ( '...', '...', '...', '...' ) ] );
        $last = 0;
      }
      if( $stake > $opts{'wager'} ){
      @row = map { green($_) } @row;
      }
      push( @table, [@row] );
      }
    }else{
    }
  }
  dump_table( table => \@table );

}

__END__

=head1 NAME

/home/apressel/bin/step.pl - [description here]

=head1 VERSION

This documentation refers to /home/apressel/bin/step.pl version 0.0.1

=head1 USAGE

    /home/apressel/bin/step.pl [options]

=head1 REQUIRED ARGUMENTS

=over

None

=back

=head1 OPTIONS

=over

None

=back

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

Requires no configuration files or environment variables.


=head1 DEPENDENCIES

None.


=head1 BUGS

None reported.
Bug reports and other feedback are most welcome.


=head1 AUTHOR

Andrew Pressel C<< apressel@nextgenfed.com >>


=head1 COPYRIGHT

Copyright (c) 2019, Andrew Pressel C<< <apressel@nextgenfed.com> >>. All rights reserved.

This module is free software. It may be used, redistributed
and/or modified under the terms of the Perl Artistic License
(see http://www.perl.com/perl/misc/Artistic.html)


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

