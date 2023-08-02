! types match the BGW-2.1 version

module typedefs
  use nrtype

  type joblist
    integer :: ne
    logical :: lwbands
    logical :: lwkpoints
    logical :: lsquare
    logical :: lhdf5
    integer :: nwstates
    integer, pointer :: iwstates(:)
    real(dp) :: sigma
    integer :: nbsv
  endtype

!--------------------------------

  type crystal
    real(DP) :: celvol !< cell volume in real space (a.u.)
    real(DP) :: recvol !< cell volume in reciprocal space (a.u.)
    real(DP) :: alat !< lattice constant in real space (a.u.)
    real(DP) :: blat !< lattice constant in reciprocal space (a.u.)
    real(DP) :: avec(3,3) !< lattice vectors in real space (alat)
    real(DP) :: bvec(3,3) !< lattice vectors in reciprocal space (blat)
    real(DP) :: adot(3,3) !< metric tensor in real space (a.u.)
    real(DP) :: bdot(3,3) !< metric tensor in reciprocal space (a.u.)
    integer :: nat !< number of atoms
    integer, pointer :: atyp(:) !< atomic species, atyp(1:nat)
    real(DP), pointer :: apos(:,:) !< atomic positions, apos(1:3,1:nat) (alat)
  end type crystal

!--------------------------------

  type kpoints
    integer :: nspinor = 1 !< nspinor = 2 if doing two-component spinor calculation; 1 is default
    integer :: nspin   !< nspin = 1 or 2; nspin = 1 when npsinor = 2
    integer :: nrk     !< number of k-points
    integer :: mnband  !< max number of bands
    integer :: nvband  !< number of valence bands
    integer :: ncband  !< number of conduction bands
    integer  :: kgrid(3) !< Monkhorst-Pack number of k-points in each direction
    real(DP) :: shift(3) !< Monkhorst-Pack shift of grid
    real(DP) :: ecutwfc            !< wave-function cutoff, in Ry
    integer, pointer :: ngk(:)     !< number of g-vectors for each k-point
    integer :: ngkmax              !< max(ngk(:))
    integer, pointer :: ifmin(:,:) !< lowest occupied band (kpoint,spin)
    integer, pointer :: ifmax(:,:) !< highest occupied band (kpoint,spin)
    real(DP), pointer :: w(:)      !< weights (kpoint) (between 0 and 1)
    real(DP), pointer :: rk(:,:)   !< k-vector (3, kpoint) in crystal coords
    real(DP), pointer :: el(:,:,:) !< band energies (band, kpoint, spin)
    real(DP), pointer :: elda(:,:,:) !< band energies before eqp correction
    real(DP), pointer :: occ(:,:,:)  !< occupations (between 0 and 1)
    integer, pointer :: degeneracy(:,:,:) !< size of deg. subspace for (band, kpoint, spin)
  end type kpoints

!--------------------------------

  type symmetry
    integer :: ntran         !< number of operations in full group
    integer :: ntranq        !< number of operations in small group of q
    real(DP) :: rq(3)        !< The q-point this ntranq belongs to
    integer :: mtrx(3,3,48)  !< symmetry matrix
    real(DP) :: tnp(3,48)    !< fractional translations
    integer :: indsub(48)    !< symmetry operations in subgroup of q
    integer :: kgzero(3,48)  !< Umklapp vectors for subgroup symmetry operations
    integer :: cell_symmetry !< 0 = cubic, 1 = hexagonal
  end type symmetry

!--------------------------------

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
    integer :: ng       !< number of G-vectors
    integer :: nFFTgridpts !< number in FFT grid = product(FFTgrid(1:3))
    real(DP) :: ecutrho !< charge-density cutoff, in Ry
    integer, pointer :: components(:,:) !< the G-vectors, in units of 2 pi / a
    integer :: FFTgrid(3)  !< gsm: FFTgrid is the size of the FFT grid, not the maximum G-vector
    integer, pointer :: index_vec(:) ! mapping to FFT grid
    real(DP), pointer :: ekin(:) !< kinetic energy of G-vectors
  end type gspace

!--------------------------------

  type mf_header_t
    integer :: version
    character(len=3) :: sheader
    character(len=32) :: sdate
    character(len=32) :: stime
    integer :: iflavor
    type(crystal) :: crys
    type(kpoints) :: kp
    type(symmetry) :: syms
    type(gspace):: gvec
  endtype mf_header_t

!--------------------------------

  type kernel_header_t

    ! Mean-field and other general information
    type(mf_header_t) :: mf !< mf header containing number of k-points, WFN cutoff, etc.

    integer :: version
    integer :: iflavor

    integer :: iscreen !< screening flag
    integer :: icutv   !< truncation flag
    real(DP) :: ecuts  !< epsilon cutoff
    real(DP) :: ecutg  !< WFN cutoff
    real(DP) :: efermi !< Fermi energy found by the code after any shift
    integer :: theory  !< 0 for GW-BSE, 1 for TD-HF, 2 for TD-DFT
    !> How many transitions blocks are there in the kernel matrix?
    !! 1 for restricted TDA kernel: vc -> v`c`
    !! 2 for restricted non-TDA kernel: {vc,cv} -> {v`c`,c`v`}  [not implemented]
    !! 4 for extended kernel: {n1,n2} -> {n1`,n2`}
    integer :: nblocks
    integer :: storage !< 0 if storing full matrix (only option supported now)
    integer :: nmat    !< number of matrices in the file (1 for bsexmat, 3 for bsedmat)
    logical :: energy_loss !< is this an energy-loss calculation?

    integer :: nvb     !< number of valence bands in the coarse grid
    integer :: ncb     !< number of conduction bands in the coarse grid
    integer :: n1b     !< nvb_co if kernel_sz==1; nvb_co + ncb_co if kernel_sz=4
    integer :: n2b     !< ncb_co if kernel_sz==1; nvb_co + ncb_co if kernel_sz=4
    integer :: ns      !< number of spins
    integer :: nspinor = 1 !< nspinor = 2 if doing two-component spinor calculation; 1 is default
    logical :: patched_sampling !< are we doing a calculation on a patch?

    ! Variables specific to kernel files
    integer :: nk      !< number of k-points
    real(DP), pointer :: kpts(:,:)
    integer :: kgrid(3)
    !> 0 for finite Q calculation with arbitrary Q (deprecated)
    !! 1 for Q=0 calculation (default)
    !! 2 use Q commensurate with WFN_co kgrid (under construction)
    integer :: qflag
    real(DP) :: center_mass_q(3)

  endtype kernel_header_t

endmodule typedefs

