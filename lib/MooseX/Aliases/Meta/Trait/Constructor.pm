package MooseX::Aliases::Meta::Trait::Constructor;
use Moose::Role;

around _generate_slot_initializer => sub {
    my $orig = shift;
    my $self = shift;
    my ($index) = @_;
    my $attr = $self->_attributes->[$index];

    my $orig_source = $self->$orig(@_);
    return $orig_source
        # only run on aliased attributes
        unless $attr->meta->can('does_role')
            && $attr->meta->does_role('MooseX::Aliases::Meta::Trait::Attribute');
    return $orig_source
        # don't run if we haven't set any aliases
        # don't run if init_arg is explicitly undef
        unless $attr->has_alias && $attr->has_init_arg;

    my $init_arg = $attr->init_arg;

    my $source = '';
    $source .= 'if (my @aliases = grep { exists $params->{$_} } (qw('
             . join(' ', @{ $attr->alias }) . '))) {' . "\n";
    $source .= '    if (exists $params->{ ' . $init_arg . ' }) {' . "\n";
    $source .= '        push @aliases, \'' . $init_arg . '\';' . "\n";
    $source .= '    }' . "\n";
    $source .= '    ' . $self->_inline_throw_error(
        "'Conflicting init_args: (' . join(', ', \@aliases) . ')'"
        ) . ' if @aliases > 1;' . "\n";
    $source .= '    $params->{ ' . $init_arg . ' } = delete '
             . '$params->{ $aliases[0] };' . "\n";
    $source .= '}' . "\n";

    return $source . $orig_source;
};

no Moose::Role;

=for Pod::Coverage

=cut

1;
