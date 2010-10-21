package CPAN::Packages;
use Moose;

use File::Slurp qw(read_file);
use IO::Uncompress::Gunzip;
use version;

=head1 NAME

CPAN::Packages - OO Interface to 02packages.details.txt.gz

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  my $pks = CPAN::Packages->new(file => 't/data/02packages.details.txt.gz');

  $pks->get_header('Columns'); # or whatever

  my $ach = $pks->get_package('ACH');
  print $ach->{'package name'}."\n";
  print $ach->{version}->stringify."\n"; version.pm version
  print $ach->{path}."\n";

  $pks->write_file; # XX not implemented yet

=head1 ATTRIBUTES

=head2 file

The name of the file we are parsing.  Should be a path to a gzipped version of
CPAN's 02packages file, since that's what this whole module is for.

=cut

has 'file' => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_file'
);

=head2 header

The header information for the packages file.

=cut

has 'header' => (
    traits => [qw(Hash)],
    is => 'rw',
    isa => 'HashRef',
    handles => {
        set_header => 'set',
        get_header => 'get',
        header_names => 'keys'
    },
    default => sub { {} }
);

=head2 packages

Returns a hashref of packages, where the key XX

=cut

has 'packages' => (
    traits => [qw(Hash)],
    is => 'rw',
    isa => 'HashRef',
    handles => {
        set_package => 'set',
        get_package => 'get',
        package_names => 'keys'
    },
    default => sub { {} }
);

=head1 METHODS

=cut

sub BUILD {
    my $self = shift;

    # If we were given a file then assume that we aren't reading anything and
    # return an empty hashref
    if(!$self->has_file) {
        $self->packages({});
        $self->header({});
    }

    my $file = $self->file;
    die "File does not exist: $file" unless -e $file;

    my $fh = IO::Uncompress::Gunzip->new( $file ) or
        die "Could not open $file: $IO::Compress::Gunzip::GunzipError";

    my $in_header = 1; # sentinel for whether or not we are in the header
    my $lines = read_file($fh, array_ref => 1);
    foreach (@{ $lines }) {
        chomp;

        $in_header = 0 if($_ =~ /^\s*$/);

        # Switch depending on where we are in the file
        if($in_header) {
            my( $field, $value ) = split /\s*:\s*/, $_, 2;

            $self->set_header($field, $value);
        } else {
            my @parts = split;

            my @cols = $self->get_columns_as_list;

            my %info;
            for(0 .. $#cols) {
                $info{$cols[$_]} = $parts[$_];
            }

            # Parse the version so we can do stuff with it.
            $info{version} = version->parse($info{version}) if defined($info{version});

            $self->set_package($parts[0], \%info);
        }
    }
}

=head2 as_string

Return this listing of packages as a string, suitable for printing as a file.

=cut

sub as_string {
    my ($self) = @_;

    my $string;
    foreach ($self->header_names) {
        $string .= "$_: ".$self->get_header."\n";
    }
    foreach (sort($self->package_names)) {
        my $info = $self->get_package($_);

        my $ver = 'undef';
        $ver = $info->{version}->stringify if defined($info->{version});

        $string .= $info->{'package name'}."\t$ver\t".$info->{path}."\n";
    }
    return $string;
}

=head2 get_columns_as_list

Returns the columns that are in this packages file (as specified by the Columns
header) as a list of strings. Note that you must have B<set> this first via
C<set_header> or a file read.

=cut

sub get_columns_as_list {
    my ($self) = @_;

    # Trim all the whitespace off
    return map { s/^\s+|\s+$//g; $_ } split(',', $self->get_header('Columns'));
}

=head2 get_header ($name)

Get the value of the specified header.

=head2 get_package ($name)

Get a hashref of info about a package.

=head2 header_names

Get a list of headers.

=head2 package_names

Get a list of package names.

=head2 set_header ($name, $value)

Set the header to the specified value.

=head2 set_package ($name, \%val)

Set a package's info.

=head1 AUTHOR

Cory G Watson, C<< <gphat at cpan.org> >>

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2010 Cory G Watson.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
