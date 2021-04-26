
module typedefs
  use nrtype

!---------------------------

  type joblist
    integer :: ne
    logical :: lwbands
    logical :: lwkpoints
    integer :: nwstates
    integer, pointer :: iwstates(:)
    real(dp) :: sigma
  endtype

!---------------------------

  type crystal
    real(DP) :: bdot(3,3)
    real(DP) :: celvol
  endtype

!------------------------

  type kpoints
    integer :: nspin   !nspin = 1 or 2
    integer :: nrk     ! # of kpoints from PWs code
    integer :: mnband  ! max number of bands
    integer :: nvband
    integer :: ncband
    integer  :: kgrid(3)
    real(DP) :: shift(3)
    integer, pointer :: ifmin(:,:)    !lowest occupied band
    integer, pointer :: ifmax(:,:)    !upper occupied band
    real(DP), pointer :: w(:)
    real(DP), pointer :: rk(:,:)
    real(DP), pointer :: el(:,:,:)
    real(DP), pointer :: elda(:,:,:)
    integer, pointer :: isort(:,:)
    integer, pointer :: nkptotal(:)
  endtype

!------------------------

  type symmetry
    integer :: ntran        !# of operations in full group
    integer :: ntranq       !# of operations in small group of q
    integer :: mtrx(48,3,3)
    real(DP) :: tnp(48,3)
    integer :: indsub(48)
    integer :: kg0(48,3)
  endtype

!------------------------

  type grid
    integer nr
    integer nf
    real(DP) :: sz
    integer, pointer :: itran(:)
    integer, pointer :: indr(:)
    integer, pointer :: kg0(:,:)
    real(DP), pointer :: r(:,:)
    real(DP), pointer :: f(:,:)
  endtype

!--------------------------------

  type gspace
    integer :: ng
    integer, pointer :: k(:,:)
    integer, pointer :: kx(:)
    integer, pointer :: ky(:)
    integer, pointer :: kz(:)
    integer kmax(3)
    integer, pointer :: indv(:) 
    real(DP), pointer :: ekin(:)
  endtype

  type polarizability
    integer :: nmtx
    integer :: nq
    integer :: icutv
    integer :: nint
    integer :: xmat
    integer, pointer :: irow(:)
    integer, pointer :: isrtx(:)
    integer, pointer :: isrtxi(:)
    integer, pointer :: kxi(:)
    real(DP) :: vcut
    real(DP) :: zcut
    real(DP) :: vcuty
    real(DP), pointer :: eden(:,:)
    real(DP), pointer :: qpt(:,:)
!#ifdef CPLX
!   complex(DPC), pointer :: gme(:,:,:)
!   complex(DPC), pointer :: xi(:,:,:)
!#else
    real(DP), pointer :: gme(:,:,:)
    real(DP), pointer :: xi(:,:,:)
!#endif
    integer :: npwsub
    integer :: ncrit
    real(DP) :: efermi
  endtype

endmodule typedefs

