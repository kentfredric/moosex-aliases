package MooseX::Aliases;
use Moose::Exporter;
use Scalar::Util qw(blessed);

=head1 NAME

MooseX::Aliases - easy aliasing of methods and attributes in Moose

=head1 SYNOPSIS

    package MyApp;
    use Moose;
    use MooseX::Aliases;

    has this => (
        isa   => 'Str',
        is    => 'rw',
        alias => 'that',
    );

    sub foo { say $self->that }
    alias foo => 'bar';

    $o = MyApp->new();
    $o->this('Hello World');
    $o->bar; # prints 'Hello World'

or

    package MyApp::Role;
    use Moose::Role;

    has this => (
        isa   => 'Str',
        is    => 'rw',
        traits => [qw(Aliased)],
        alias => 'that',
    );

    sub foo { say $self->that }
    alias foo => 'bar';

=head1 DESCRIPTION

The MooseX::Aliases module will allow you to quickly alias methods in Moose.
It provides an alias parameter for has() to generate aliased accessors as well
as the standard ones. Attributes can also be initialized in the constructor via
their aliased names.

=cut

=head1 EXPORTS

=cut

Moose::Exporter->setup_import_methods(
    with_caller               => ['alias'],
    attribute_metaclass_roles => ['MooseX::Aliases::Meta::Trait::Attribute'],
);

sub _get_method_metaclass {
    my ($method) = @_;

    my $meta = Class::MOP::class_of($method);
    if ($meta->can('does_role')
     && $meta->does_role('MooseX::Aliases::Meta::Trait::Method')) {
        return blessed($method);
    }
    else {
        return Moose::Meta::Class->create_anon_class(
            superclasses => [blessed($method)],
            roles        => ['MooseX::Aliases::Meta::Trait::Method'],
            cache        => 1,
        )->name;
    }
}

=head2 alias METHODNAME ALIAS

Gives the METHODNAME method an alias of ALIAS.

=cut

sub alias {
    my ( $caller, $alias, $orig ) = @_;
    my $meta   = Class::MOP::class_of($caller);
    my $method = $meta->find_method_by_name($orig);
    if (!$method) {
        $method = $meta->find_method_by_name($alias);
        if ($method) {
            Carp::cluck(
                q["alias $from => $to" is deprecated, please use ]
              . q["alias $to => $from"]
            );
            ($alias, $orig) = ($orig, $alias);
        }
    }
    Moose->throw_error("cannot find method $orig to alias") unless $method;
    $meta->add_method(
        $alias => _get_method_metaclass($method)->wrap(
            sub { shift->$orig(@_) }, # goto $_[0]->can($orig) ?
            package_name => $caller,
            name         => $alias,
            aliased_from => $orig
        )
    );
}

=head1 BUGS/CAVEATS

Currently, to use MooseX::Aliased in a role, you will need to explicitly
associate the metaclass trait with your attribute. This is because Moose won't
automatically apply metaclass traits to attributes in roles. The example in
L<SYNOPSIS> should work.

Please report any bugs through RT: email
C<bug-moosex-aliases at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=MooseX-Aliases>.

=head1 SEE ALSO

L<Moose>

L<Method::Alias>

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc MooseX::Aliases

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-Aliases>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-Aliases>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-Aliases>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-Aliases>

=back

=head1 AUTHORS

  Jesse Luehrs <doy at tozt dot net>

  Chris Prather (chris@prather.org)

  Justin Hunter <justin.d.hunter at gmail dot com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
