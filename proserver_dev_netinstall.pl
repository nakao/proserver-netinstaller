#!/usr/bin/perl

=head1 NAME

proserver_dev_netinstall.pl

=head1 SYNOPSIS

  proserver_dev_netinstall.pl -b|--build_param_str BUILD_STRING [options]

options: 

 -h|--help                Show this message 
 -d|--dev                 Use the developement version of both ProServer
                            and bioperl from Subversion/CVS
 --build_param_str=<args> Use this string to set Makefile.PL parameters
                            such as CONF or PREFIX for ProServer 
                            installation
 --install_param_str=<args>
                           Use this string to predefine 'make install' 
                            parameters such as CONF or PREFIX for
                            ProServer installation
 --skip_start             Don't wait for 'Enter' at program start

=head1 DESCRIPTION

Net-based installer of ProServer

Save this to disk as "proserver_dev_netinstall.pl" and run:

   [sudo] perl proserver_dev_netinstall.pl

=cut


use warnings;
use strict;
use CPAN;
use Config;
use Getopt::Long;
use Pod::Usage;
use File::Copy 'cp';
use File::Temp qw(tempdir);
use LWP::Simple;
use Cwd;

my ( $show_help, $build_param_string, $working_dir,
     $binaries, $make, $tmpdir, $skip_start, $install_param_string, $PERL);
$PERL = $^X;
$build_param_string = "";
$install_param_string = "";

BEGIN {
  GetOptions(
        'h|help'              => \$show_help,             # Show help and exit
        'build_param_str=s'   => \$build_param_string,    # Build parameters
        'install_param_str=s' => \$install_param_string,
        'skip_start'          => \$skip_start,
        )
        or pod2usage(2);
  pod2usage(2) if $show_help;
  

  print STDERR "\nAbout to install ProServer and all its prerequisites.\n",
               "\nPress return when you are ready to start!\n";
  my $h = <> unless $skip_start;


  print STDERR "*** Installing Perl files needed for a net-based install ***\n";

  eval "CPAN::Config->load";
  eval "CPAN::Config->commit";

  $working_dir = getcwd;
  $tmpdir = tempdir(CLEANUP=>1) or die "Could't create temporary directory: $!";

  $binaries = $Config{'binexp'};
  $make     = $Config{'make'};

  eval "use Archive::Zip ':ERROR_CODES',':CONSTANTS'";
  my @pkgs = ('YAML',
	      'Archive::Zip',
	      'HTML::Tagset',
	      'LWP::Simple',
	      'Archive::Tar',
	      'Digest::SHA',
      );
  foreach (@pkgs) {
      CPAN::Shell->install($_);
  }
  1;
};

use Archive::Tar;
use CPAN '!get';


use constant BIOPERL_REQUIRES     => '1.005002';  # sorry for the redundancy
use constant PROSERVER_DEFAULT    => '2.8';

unless ( eval "use GD 2.31; 1" ) {
    print STDERR "Installing GD via CPAN...\n";
    CPAN::Shell->install('GD');
}



print STDERR "\n*** Installing prerequisites for BioPerl ***\n";
my @pkgs = ('GD::SVG',
	    'IO::String',
	    'Text::Shellwords',
	    'CGI::Session',
	    'File::Temp',
	    'Class::Base',
	    'Digest::MD5',
	    'Statistics::Descriptive',
);
foreach (@pkgs) {
    CPAN::Shell->install($_);
}

my $version = BIOPERL_REQUIRES;
if (!(eval "use Bio::Perl $version; 1")) {
  print STDERR "\n*** Installing BioPerl ***\n";
  CPAN::Shell->install('Module::Build');
  chdir $tmpdir;
  my $package_name = 'bioperl-1.5.2_102';
  my $bioperl_core_tar_gz => 'http://bioperl.org/DIST/current_core_unstable.tar.gz';
  my $cmd = "curl -O $bioperl_core_tar_gz";
  print STDERR "Checking out $package_name...\n";
  system($cmd) == 0 or die "Failed to download the BioPerl Core: $!\n";
  system("tar zxvf current_cre_unstable.tar.gz") == 0;
  chdir "./$package_name";
  my $build_str = './Build';
  system("$PERL $build_str.PL --yes=1")   == 0
      or die "Couldn't run $PERL Build.PL command\n";
  system("$build_str install --uninst 1") == 0;
} else {
  print STDERR "BioPerl is up to date.\n";
}




print STDERR "\n *** Installing ProServer (Bio-Das-ProServer) ***\n";
@pkgs = ('File::Spec',
	 'POSIX',
	 'CGI',
	 'Socket',
	 'POE',
	 'Getopt::Long',
	 'Sys::Hostname',
	 'POE::Filter::HTTPD',
	 'POE::Wheel::ReadWrite',
	 'POE::Wheel::SocketFactory',
	 'HTTP::Request', 'HTTP::Response', 'HTTP::Date',
	 'Config::IniFiles',
	 # 'Compress::Zlib',
	 'HTML::Entities',
	 'DBI',
	 'LWP::UserAgent',
	 'Cache::FileCache',
	 'Net::IP',
	 'Bio::Das::Lite',
         # 'Bio::DB::Flat::OBDAIndex', # 'Bio::DB::Flat'
         # 'Bio::SeqIO',
         # 'Bio::EnsEMBL::DBSQL::DBAdaptor',
         # 'Bio::EnsEMBL::Registry',
         # 'Bio::Pfam::Structure::Chainset',
    );
foreach (@pkgs) {
    CPAN::Shell->install($_);
}

my $package_name = 'Bio-Das-ProServer';
my $svn_co = "svn co https://proserver.svn.sf.net/svnroot/proserver/trunk $package_name";
print STDERR "Checking out $package_name...\n";
chdir $tmpdir;
system($svn_co) == 0 or die "Failed to check out the ProServer from SVN: $!\n";
chdir "./$package_name";
system("$PERL Makefile.PL $build_param_string") == 0
    or die "Couldn't run $PERL Makefile.PL command\n";
system("$make install UNINST=1 $install_param_string") == 0;

exit 0;

END {
}
