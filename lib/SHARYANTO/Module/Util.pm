package SHARYANTO::Module::Util;

use 5.010001;
use strict;
use warnings;

use Module::Path qw(module_path);
use SHARYANTO::Dist::Util qw(packlist_for);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       is_xs
                       is_pp
               );

sub is_xs {
    my ($mod, $opts) = @_;
    die "Please specify module\n" unless $mod;

    $opts //= {};
    $opts->{warn} //= 0;
    my $warn = $opts->{warn};

    my $path = packlist_for($mod);
    {
        last unless $path;
        my $fh;
        unless (open $fh, '<', $path) {
            warn "Can't open .packlist $path: $!\n" if $warn;
            last;
        }
        while (<$fh>) {
            chomp;
            if (/\.(bs|so|[Dd][Ll][Ll])\z/) {
                return 1;
            }
        }
        return 0;
    }

    $path = module_path($mod);
    {
        last unless $path;
        local $/;
        my $fh;
        unless (open $fh, '<', $path) {
            warn "Can't open module file $path: $!" if $warn;
            last;
        }
        while (<$fh>) {
            if (m!^\s*use XSLoader\b!m) {
                return 1;
            }
        }
        return 0;
    }

    warn "Can't determine whether $mod is XS: all methods tried\n" if $warn;
    undef;
}

sub is_pp {
    my ($mod, $opts) = @_;
    my $is_xs = is_xs($mod, $opts);
    return undef unless defined($is_xs);
    !$is_xs;
}

# VERSION

1;
# ABSTRACT: Module-related utilities

=head1 SYNOPSIS

 use SHARYANTO::Module::Util qw(
     is_xs is_pp
 );

 say "Class::XSAccessor is an XS module" if is_xs("Class/XSAccessor.pm");
 say "JSON::PP is a pure-Perl module" if is_pp("JSON::PP");


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 is_xs($mod, \%opts) => BOOL

Return true if module C<$mod> is an XS module, false if a pure Perl module, or
undef if can't determine either. C<$mod> value can be in the form of
C<Package/SubPkg.pm> or C<Package::SubPkg>. The following ways are tried, in
order:

=over

=item * Looking at the C<.packlist>

If a .{bs,so,dll} file is listed in the C<.packlist>, then it is assumed to be
an XS module. This method will fail if there is no C<.packlist> available (e.g.
core or uninstalled or when the package management strips the packlist), or if a
dist contains both pure-Perl and XS.

=item * Looking at the source file for usage of C<XSLoader>

If the module source code has something like C<use XSLoader;> then it is assumed
to be an XS module. This is currently implemented using a simple regex, so it is
somewhat brittle.

=back

Other methods will be added in the future (e.g. a database like in
L<Module::CoreList>, consulting MetaCPAN, etc).

Options:

=over

=item * warn => BOOL (default: 0)

If set to true, will warn to STDERR if fail to determine.

=back

=head2 is_pp($mod, \%opts) => BOOL

The opposite of C<is_xs>, return true if module C<$mod> is a pure Perl module.
See C<is_xs> for more details.


=head1 SEE ALSO

L<SHARYANTO>

=cut
