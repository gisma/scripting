#!/usr/bin/env perl
$^W = 1;
use strict;
use Getopt::Long;
use DateTime;
use DateTime::Astro::Sunrise;

my $cvsid = '$Id: sunrise,v 1.2 2010-12-16 21:06:56 gilles Exp $';

my %altitudes =
  (
   center => 0, # center of sun's disk touches a mathematical horizon
   limb => -0.25, # sun's upper limb touches a mathematical horizon
   rcenter => -0.583, # center of sun's disk looks like it touches the horizon
   rlimb => -0.833, # sun's upper limb looks like it touches the horizon
   civil => -6, # reading outside requires artificial illumination
   nautical => -12, # navigation using a sea horizon no longer possible
   amateur => -15, # the sky is dark enough for most astronomical observations
   astronomical => -18, # the sky is completely dark
  );

sub help_and_exit {
    print "Usage: $0 [OPTION]...", <<'EOF';
Show the time of sunrise and sunset at the given location.

  -x, --longitude=NUM   longitude (degrees, >0 for east or xxxE or xxxW)
  -y, --latitude=NUM    latitude (degrees, >0 for north or xxxN or xxxS)
  -a, --altitude=NUM    sun altitude (pass 'help' to list symbolic names)
  -i, --iter=N          number of iterations (rarely needed)
  -f, --format=FORMAT   time display format
  -d, --date=DATE       day to consider (default: today)
      --help            display this help and exit
      --version         output version information and exit 
EOF
    exit;
}

sub version_and_exit {
    print "sunrise $cvsid\n";
    exit;
}

sub validate_xy {
    my ($s, $name, $neg, $pos) = @_;
    die "No $name specified!" unless defined $s;
    $s =~ tr/\t //;
    my $negative = ($s =~ s/^([-+])// && $1 eq '-');
    my $opposite = ($s =~ s/(\Q$pos\E|\Q$neg\E)$//i && lc($1) eq lc($neg));
    my $sign = ($negative ^ $opposite ? '-' : '+');
    die "Badly formed number in $name!\n"
      unless $s =~ /^(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$/;
    $s .= ".0" unless $s =~ /\./;
    return "$sign$s";
}

sub sun_rise_set {
    my ($long, $lat, $alt, $iter, $dt) = @_;
    my $sr = DateTime::Astro::Sunrise->new($long, $lat, $alt, $iter);
    my ($rise, $set) = $sr->sunrise($dt);
    my $tz = $dt->time_zone;
    $rise->set_time_zone($tz);
    $set->set_time_zone($tz);
    return $rise, $set;
}

sub main {
    ## Default values
    my ($long, $lat) = (undef, undef);
    my $alt = $altitudes{rlimb};
    my $iter = 3;
    my $locale = "en_IE";
    my $time_format = "%c %Z";
    my $dt = undef;

    ## Command line parsing
    GetOptions(
               "x|longitude=s" => \$long,
               "y|latitude=s" => \$lat,
               "a|altitude=s" => \$alt,
               "i|iter=i" => \$iter,
               "f|format=s" => \$time_format,
               "d|date=s" => \$dt,
               "help" => \&help_and_exit,
               "version" => \&version_and_exit,
               ) or die "$0: invalid command line (try --help)\n";
    # TODO: options for locale?, timezone
    if ($alt eq 'help') {
        foreach my $z (sort {$a->[1] <=> $b->[1]}
                       map {[$_,$altitudes{$_}]} keys %altitudes) {
            printf "%-19s %g\n", @$z;
        }
        exit;
    }
    $long = validate_xy($long, "longitude", "w", "e");
    $lat = validate_xy($lat, "latitude", "s", "n");
    $alt = $altitudes{lc($alt)} if exists $altitudes{lc($alt)};
    die "Badly formed altitude (try --altitude=help)!"
      unless $alt =~ /^[-+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$/;
    if (defined $dt) {
        require Date::Manip;
        $dt = DateTime->new(
                Date::Manip::UnixDate(
                  Date::Manip::ParseDateString($dt),
                  qw[year %Y month %m day %d],
                  qw[hour %H minute %M second %S],
                  qw[time_zone %z]));
    } else {
        $dt = DateTime->now;
        $dt->set_time_zone("local");
    }
    ## Compute and display
    my ($rise, $set) = sun_rise_set($long, $lat, $alt, $iter, $dt);
    $rise->set_locale($locale);
    $set->set_locale($locale);
    print $rise->strftime($time_format), "\n";
    print $set->strftime($time_format), "\n";
}

main(@ARGV);
