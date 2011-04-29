package MooseX::Aliases::Meta::Trait::Role::ApplicationToClass;
use Moose::Role;

around apply => sub {
    my $orig  = shift;
    my $self  = shift;
    my ($role, $class) = @_;

    $class = Moose::Util::MetaRole::apply_metaroles(
        for             => $class,
        class_metaroles => {
            ((Moose->VERSION >= 1.9900)
                ? (class =>
                       [ 'MooseX::Aliases::Meta::Trait::Class' ])
                : (constructor =>
                       [ 'MooseX::Aliases::Meta::Trait::Constructor' ])),
        }
    );

    $self->$orig( $role, $class );
};

no Moose::Role;

1;
