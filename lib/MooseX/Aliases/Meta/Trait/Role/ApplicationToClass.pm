package MooseX::Aliases::Meta::Trait::Role::ApplicationToClass;
use Moose::Role;

around apply => sub {
    my $orig  = shift;
    my $self  = shift;
    my ($role, $class) = @_;

    $class = Moose::Util::MetaRole::apply_metaroles(
        for             => $class,
        class_metaroles => {
            class => [ 'MooseX::Aliases::Meta::Trait::Class' ],
        }
    );

    $self->$orig( $role, $class );
};

no Moose::Role;

=for Pod::Coverage

=cut

1;
