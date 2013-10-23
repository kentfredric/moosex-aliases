package MooseX::Aliases::Meta::Trait::Class;
use Moose::Role;

our $MX_EXCEPTIONS = eval { Moose->VERSION('2.1100'); 1 };


around _inline_slot_initializer => sub {
    my $orig = shift;
    my $self = shift;
    my ($attr, $index) = @_;

    my @orig_source = $self->$orig(@_);
    return @orig_source
        # only run on aliased attributes
        unless $attr->meta->can('does_role')
            && $attr->meta->does_role('MooseX::Aliases::Meta::Trait::Attribute');
    return @orig_source
        # don't run if we haven't set any aliases
        # don't run if init_arg is explicitly undef
        unless $attr->has_alias && $attr->has_init_arg;

    my $init_arg = $attr->init_arg;

    my $error_code;
    if ($MX_EXCEPTIONS) {
        $error_code = $self->_inline_throw_exception(
            '"Aliases::InitArgConflict" => init_arg_aliases => \@aliases');
    }
    else {
        $error_code = $self->_inline_throw_error(
            '"Conflicting init_args: (" . join(", ", @aliases) . ")"');
    }

    return (
        'if (my @aliases = grep { exists $params->{$_} } (qw('
          . join(' ', @{ $attr->alias }) . '))) {',
            'if (exists $params->{' . $init_arg . '}) {',
                'push @aliases, \'' . $init_arg . '\';',
            '}',
            'if (@aliases > 1) {',
                $error_code .';',
            '}',
            '$params->{' . $init_arg . '} = delete $params->{$aliases[0]};',
        '}',
        @orig_source,
    );
};

no Moose::Role;

=for Pod::Coverage

=cut

1;
