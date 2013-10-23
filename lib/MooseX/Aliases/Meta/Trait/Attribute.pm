package MooseX::Aliases::Meta::Trait::Attribute;
use Moose::Role;
use Moose::Util::TypeConstraints;
our $MX_EXCEPTIONS = eval { Moose->VERSION('2.1100'); 1 };
Moose::Util::meta_attribute_alias 'Aliased';
# ABSTRACT: attribute metaclass trait for L<MooseX::Aliases>

=head1 SYNOPSIS

    package MyApp::Role;
    use Moose::Role;
    use MooseX::Aliases;

    has this => (
        isa   => 'Str',
        is    => 'rw',
        alias => 'that',
    );

=head1 DESCRIPTION

This trait adds the C<alias> option to attribute creation. It is automatically
applied to all attributes when C<use MooseX::Aliases;> is run.

=cut

subtype 'MooseX::Aliases::ArrayRef', as 'ArrayRef[Str]';
coerce  'MooseX::Aliases::ArrayRef', from 'Str', via { [$_] };

has alias => (
    is         => 'ro',
    isa        => 'MooseX::Aliases::ArrayRef',
    auto_deref => 1,
    coerce     => 1,
    predicate  => 'has_alias',
);

after install_accessors => sub {
    my $self = shift;
    my $class_meta = $self->associated_class;
    my $orig_name  = $self->get_read_method;
    my $orig_meth  = $self->get_read_method_ref;
    for my $alias ($self->alias) {
        $class_meta->add_method(
            $alias => MooseX::Aliases::_get_method_metaclass($orig_meth)->wrap(
                sub { shift->$orig_name(@_) }, # goto $_[0]->can($orig_name) ?
                package_name => $class_meta->name,
                name         => $alias,
                aliased_from => $orig_name,
            )
        );
    }
};

around initialize_instance_slot => sub {
    my $orig = shift;
    my $self = shift;
    my ($meta_instance, $instance, $params) = @_;

    return $self->$orig(@_)
        # don't run if we haven't set any aliases
        # don't run if init_arg is explicitly undef
        unless $self->has_alias && $self->has_init_arg;

    if (my @aliases = grep { exists $params->{$_} } @{ $self->alias }) {
        if (exists $params->{ $self->init_arg }) {
            push @aliases, $self->init_arg;
        }
        if ( @aliases > 1 ) {
            if ($MX_EXCEPTIONS) {
                require Moose::Util;
                Moose::Util::throw_exception(
                    "Aliases::InitArgConflict" => init_arg_aliases =>
                      \@aliases );
            }
            else {
                $self->associated_class->throw_error(
                    'Conflicting init_args: (' . join( ', ', @aliases ) . ')' );
            }
        }
        $params->{ $self->init_arg } = delete $params->{ $aliases[0] };
    }

    $self->$orig(@_);
};

no Moose::Role;

1;
