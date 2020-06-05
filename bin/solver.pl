#! /usr/bin/env perl

use 5.020;
use warnings;
use autodie;

use Getopt::Long;

use Toolkit;

my %opts = ( infile => 'test.txt', );
if ( !GetOptions( \%opts, 'infile=s' ) ) {
  die("Invalid incantation\n");
}

main();
exit(0);

sub main {

  my $board = readBoard();

  message();
  foreach my $row ( 0 .. 8 ) {
    foreach my $col ( 0 .. 8 ) {
      print("[$board->[$row][$col]]");
    }
    print("\n");
  }

  my @placed = (1);
  while ( scalar(@placed) > 0 ) {
    @placed = ();

    foreach my $row ( 0 .. 8 ) {
      foreach my $col ( 0 .. 8 ) {
        my $value = $board->[$row][$col];
        if ( $value eq '*' ) {
          my @set = ( 1 .. 9 );
          @set = checkRow( $board, $row, @set );

          #        quick( $row, $col => '=>' => @set );
          @set = checkColumn( $board, $col, @set );

          #        quick( $row, $col => '=>' => @set );
          @set = checkGrid( $board, $row, $col, @set );

          @set = checkBlocked( $board, $row, $col, @set );

          #                  quick( $row, $col => '=>' => @set );

          if ( scalar(@set) == 1 ) {
            push( @placed, [ $row, $col => '=>' => @set ] );
            $board->[$row][$col] = $set[0];
          }
        }
      }
    }

    if ( scalar(@placed) > 0 ) {
      message();
      quick( @{$_} ) foreach @placed;

      message( "placed => " . scalar(@placed) );
      foreach my $row ( 0 .. 8 ) {
        foreach my $col ( 0 .. 8 ) {
          print("[$board->[$row][$col]]");
        }
        print("\n");
      }
    }
  }
}

sub checkBlocked {
  my ( $board, $row, $col, @set ) = @_;

  my $r = int( $row / 3 );
  my $c = int( $col / 3 );

  #  quick( $row, $col, "=>", "$r,$c" );

  my @retval;

  foreach my $v (@set) {

    #    message($v);
    my %possible;
    my $match = 0;
    foreach my $i ( 0 .. 2 ) {
      my $rix = $r * 3 + $i;
      foreach my $j ( 0 .. 2 ) {
        my $cix = $c * 3 + $j;

        my @rc = checkRow( $board, $rix, $v );

        #        quick( 'R', $i, => @rc );
        if ( scalar(@rc) == 1 ) {
          @rc = checkColumn( $board, $cix, $v );

          #          quick( 'C', $j => @rc );
          if ( scalar(@rc) == 1 ) {
            if ( $board->[$rix][$cix] eq '*' ) {

              #              quick( here => $v => 'possible' );
              $possible{"$rix;$cix"} = $v;
            }
          }
        }
      }

    }
    if ( scalar keys %possible == 1 ) {
      foreach my $val ( keys %possible ) {

        #        quick($val, "$row;$col");
        push( @retval, $possible{$val} ) if ( $val eq "$row;$col" );
      }
    }
  }

  return wantarray ? @retval : \@retval;
}

sub checkGrid {
  my ( $board, $row, $col, @set ) = @_;

  my $r = int( $row / 3 );
  my $c = int( $col / 3 );

  #  quick( $row, $col, "=>", "$r,$c" );

  my @retval;
  foreach my $v (@set) {
    my $match = 0;
    foreach my $i ( 0 .. 2 ) {
      foreach my $j ( 0 .. 2 ) {

        #        print("[$board->[$r*3+$i][$c*3+$j]]");
        next unless ( $board->[ $r * 3 + $i ][ $c * 3 + $j ] =~ /^\d$/ );
        $match = 1 if ( $v == $board->[ $r * 3 + $i ][ $c * 3 + $j ] );
      }

      #      print("\n");
    }
    push( @retval, $v ) unless ($match);
  }

  return wantarray ? @retval : \@retval;
}

sub checkColumn {
  my ( $board, $col, @set ) = @_;

  my @retval;
  foreach my $i (@set) {
    my $match = 0;
    foreach my $row ( 0 .. 8 ) {
      next unless ( $board->[$row][$col] =~ /^\d$/ );
      $match = 1 if ( $i == $board->[$row][$col] );
    }
    push( @retval, $i ) unless ($match);
  }

  return wantarray ? @retval : \@retval;
}

sub checkRow {
  my ( $board, $row, @set ) = @_;

  my @retval;
  foreach my $i (@set) {
    my $match = 0;
    foreach my $col ( 0 .. 8 ) {
      next unless ( $board->[$row][$col] =~ /^\d$/ );
      $match = 1 if ( $i == $board->[$row][$col] );
    }
    push( @retval, $i ) unless ($match);
  }

  return wantarray ? @retval : \@retval;
}

sub readBoard {
  my @retval;

  open( my $fh, '<', $opts{'infile'} );
  while ( my $ln = <$fh> ) {
    chomp($ln);

    my @row = split( //, $ln );
    push( @retval, \@row );
  }

  close($fh);

  return wantarray ? @retval : \@retval;
}

__END__ 

=head1 NAME

solver.pl - [description here]

=head1 VERSION

This documentation refers to solver.pl version 0.0.1

=head1 USAGE

    solver.pl [options]

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

Copyright (c) 2020, Andrew Pressel C<< <apressel@nextgenfed.com> >>. All rights reserved.

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

