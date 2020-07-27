#! /usr/bin/env perl

use 5.020;
use warnings;
use autodie;

use DateTime;
use Getopt::Long;
use JSON;
use LWP;
use Text::FIGlet;

use Toolkit;

my %opts = (cacheDir => '.',);
if(!GetOptions(\%opts, 'andrew', 'sarah', 'verbose', 'commit')) {
  die("Invalid incantation\n");
}

main();
exit(0);

sub main {

  my $font = Text::FIGlet->new(
    -d => '/usr/local/Cellar/figlet/2.2.5/share/figlet/fonts',
    -f => 'standard'
  );

  if($opts{'sarah'}) {
    my $out = $font->figify(-A => "Sarah");
    message(green($out));
    reportUser('7232182');
  }

  if($opts{'andrew'}) {
    my $out = $font->figify(-A => "Andrew");
    message(green($out));
    reportUser('28538797');
  }

}

sub reportUser {
  my ($userId) = @_;

  my $obj = getResultsPage($userId);

  printObject($obj) if($opts{'verbose'});

  my $eventId = shift @{$obj->{'virtualEventIds'}};

  my ($yr, $mn, $dy) =
    unpack('A4xA2xA2', $obj->{'eventStartDates'}{$eventId});
  my $dti = DateTime->new(year => $yr, month => $mn, day => $dy);

  ($yr, $mn, $dy) = unpack('A4xA2xA2', $obj->{'eventEndDates'}{$eventId});
  my $dtf = DateTime->new(year => $yr, month => $mn, day => $dy);

  my $today = DateTime->now();

  my $total    = $dtf->delta_days($dti)->delta_days();
  my $progress = $dti->delta_days($today)->delta_days();
  my $remain   = $dtf->delta_days($today)->delta_days();
  my $pctTime  = sprintf('%.1f', 100 * ($progress / $total));

  my $results = shift @{$obj->{'results'}};
  my $goal    = $results->{'result_tally_goal'};
  $goal =~ s/[^0-9.]//go;
  my $distance = $results->{'result_tally_value'};
  $distance =~ s/[^0-9.]//go;
  my $togo = $goal - $distance;

  my $milesPerDay = sprintf('%.1f', $togo / $remain);
  my $pctMiles = sprintf('%.1f', 100 * ($distance / $goal));

  my $wide = length($distance);
  message(
    "Event: " . $dti->date() . " through " . $dtf->date(),
    sprintf(
      "  Progress: %" . $wide . "s of %7s days  (%.1f%%)",
      $progress, $total, $pctTime
    ),
    sprintf(
      "  Distance: %" . $wide . "s of %7s miles (%.1f%%)",
      $distance, $goal, $pctMiles
    ),
  );

  if($pctMiles < $pctTime) {
    my $delta = $pctTime - $pctMiles;
    my $miles = $goal * ($delta / 100);

    message(red(sprintf("Behind:  %3.1f miles (%.1f%%)", $miles, $delta)));
  } else {
    my $delta = $pctMiles - $pctTime;
    my $miles = $goal * ($delta / 100);

    message(green(sprintf("Ahead:  %3.1f miles (%.1f%%)", $miles, $delta)));
  }

  $wide = length($togo);
  message(
    "To complete:",
    sprintf("  Days:  %" . $wide . "d remaining", $remain),
    sprintf("  Miles: %" . $wide . ".1f to go",   $togo),
    sprintf("  Rate:  %" . $wide . ".1f mpd",     $milesPerDay),
  );
}

sub getResultsPage {
  my ($userId) = @_;

  my $retval = undef;
  my $cache  = "$opts{'cacheDir'}/$userId.html";
  #  if ( -f $cache ) {
  #    open( my $fh, '<', $cache );
  #    local $/ = undef;
  #    $retval = <$fh>;
  #    close($fh);
  #  }

  if(!defined($retval)) {

    my $ua = LWP::UserAgent->new(agent => 'presselam');
    my $url =
"https://runsignup.com/Race/Results/91138/LookupParticipant/LtYz?resultSetId=194836&userId=$userId";
    $url =
"https://runsignup.com/Race/Results/91138/IndividualResult/LtYz?resultSetId=194836";

    my $req = HTTP::Request->new(POST => $url);
    $req->header('accept' => 'application/json');
    $req->header(
      'content-type' => 'application/x-www-form-urlencoded; charset=UTF-8');
    $req->content("userIdCsv=$userId");

    my $resp = $ua->request($req);
    if($resp->is_success()) {
      $retval = $resp->decoded_content();
      open(my $fh, '>', $cache);
      $fh->print($retval);
      close($fh);
    } else {
      quick(error => $resp->status_line());
    }
  }

  my $json = JSON->new->allow_nonref();
  return $json->decode($retval);
}

__END__

=head1 NAME

bin/buckeye.pl - [description here]

=head1 VERSION

This documentation refers to bin/buckeye.pl version 0.0.1

=head1 USAGE

    bin/buckeye.pl [options]

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

